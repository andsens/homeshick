#!/bin/bash

function symlink {
	[[ ! $1 ]] && help symlink
	local castle=$1
	castle_exists "$castle"
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		ignore 'ignored' "$castle"
		return $EX_SUCCESS
	fi
	oldIFS=$IFS
	IFS=$'\n'
	for filename in $(get_repo_files $repo/home); do
		remote="$repo/home/$filename"
		IFS=$oldIFS
		local=$HOME/$filename

		if [[ -e $local || -L $local ]]; then
			# $local exists (but may be a dead symlink)
			if [[ -L $local && $(readlink "$local") == $remote ]]; then
				# $local symlinks to $remote.
				if [[ -d $remote && ! -L $remote ]]; then
					# If $remote is a directory -> legacy handling.
					rm "$local"
				else
					# $local points at $remote and $remote is not a directory
					ignore 'identical' "$filename"
					continue
				fi
			else
				# $local does not symlink to $remote
				if [[ -d $local && -d $remote && ! -L $remote ]]; then
					# $remote is a real directory while
					# $local is a directory or a symlinked directory
					# we do not take any action regardless of which it is.
					ignore 'identical' "$filename"
					continue
				fi
				if $SKIP; then
					ignore 'exists' "$filename"
					continue
				fi
				if ! $FORCE; then
					prompt_no 'conflict' "$filename exists" "overwrite?" || continue
				fi
				# Delete $local. If $remote is a real directory,
				# $local must be a file (because of all the previous checks)
				rm -rf "$local"
			fi
		fi

		if [[ ! -d $remote || -L $remote ]]; then
			# $remote is not a real directory so we create a symlink to it
			pending 'symlink' "$filename"
			ln -s "$remote" "$local"
		else
			pending 'directory' "$filename"
			mkdir "$local"
		fi

		success
	done
	return $EX_SUCCESS
}

function get_repo_files {
	local dir=$1
	local prefix=''
	if [[ -n $2 ]]; then
		dir="$dir/$2"
		prefix="$2/"
	fi
	local paths=""
	# Loop through the files tracked by git and compute
	# a list of their parent directories.
	for path in $(cd $dir && git ls-files); do
		# Don't add a newline to the beginning of the list
		[[ -n $paths ]] && paths="$paths\n"
		paths="$paths$prefix$path"
		# Get all directory paths up to the root.
		# We won't ever hit '/' here since ls-files
		# always shows paths relative to the repo root.
		while [[ $path =~ '/' ]]; do
			path=$(dirname $path)
			paths="$prefix$path\n$paths"
		done
	done

	for submodule in $(cd $dir; git submodule --quiet foreach 'printf "%s\n" "$path"'); do
		paths="$(get_repo_files $dir $submodule)\n$paths"
	done

	printf "$paths" | sort | uniq
}
