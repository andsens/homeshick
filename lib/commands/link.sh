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

function get_repo_dirs {
	# Loop through the files tracked by git and compute
	# a list of their parent directories.
	# The root of repo we are looking at, will not change.
	local root=$1
	# Check if this is the root invocation.
	if [[ -n $2 ]]; then
		# The relative path to the submodule:
		relpath="$2/"
	else
		# First invocation, the repo_dir is just the root.
		local repo_dir=$root
		local relpath=''
	fi
	(
		local path
		while read path; do
			printf "%s\n" "$relpath$path"
			# Get all directory paths up to the root.
			# We won't ever hit '/' here since ls-files
			# always shows paths relative to the repo root.
			while [[ $path =~ '/' ]]; do
				path=$(dirname "$path")
				printf "%s\n" "$relpath$path"
			done
		done < <(cd "$repo_dir" && git ls-files | xargs -I{} dirname "{}" | sort | uniq)
	) | sort | uniq
}

function get_repo_files {
	# This function descends recursively through all submodules
	# of a repository and makes the paths returned by `git ls-files`
	# relative to the root repo.
	# All directory paths are computed as well.
	# The root of repo we are looking at, will not change.
	local root=$1
	# Check if this is the root invocation.
	if [[ -n $2 ]]; then
		# The path to the current repo we are looking at:
		repo_dir="$root/$2"
		# The relative path to the submodule:
		relpath="$2/"
	else
		# First invocation, the repo_dir is just the root.
		local repo_dir=$root
		local relpath=''
	fi
	pending "list files" "$repo_dir" >&2
	(
		# Get files (+ submodule path prefix).
		local path
		while read path; do
			printf "%s\n" "$relpath$path"
		done < <(cd "$repo_dir" && git ls-files)

		# Get all directories (+ submodule path prefix).
		get_repo_dirs "$root" "$relpath"

		# Recurse on all submodule children (not descendants, i.e. immediate
		# children), passing the relative path to the submodule as the 2nd arg.
		for submodule in $(cd "$repo_dir"; git submodule --quiet foreach 'printf "%s\n" "$path"'); do
			get_repo_files "$root" "$relpath$submodule"
		done
	) | sort | uniq
	success "list files" "$repo_dir" >&2
}
