#!/bin/bash

function symlink {
	[[ ! $1 ]] && help symlink
	local castle=$1
	castle_exists 'link' "$castle"
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		ignore 'ignored' "$castle"
		return $EX_SUCCESS
	fi
	# Run through the repo files using process substitution.
	# The get_repo_files call is at the bottom of this loop.
	# We set the IFS to nothing and the separator for `read' to NUL so that we
	# don't separate files with newlines in their name into two iterations.
	# `read's stdin comes from a third unused file descriptor because we are
	# using the real stdin for prompting the user whether he wants to overwrite or skip
	# on conflicts.
	while IFS= read -d $'\0' -r filename <&3 ; do
		remote="$repo/home/$filename"
		local="$HOME/$filename"

		if [[ -e $local || -L $local ]]; then
			# $local exists (but may be a dead symlink)
			if [[ -L $local && $(readlink "$local") == "$remote" ]]; then
				# $local symlinks to $remote.
				if [[ -d $remote && ! -L $remote ]]; then
					# If $remote is a directory -> legacy handling.
					rm "$local"
				else
					# $local points at $remote and $remote is not a directory
					if $VERBOSE; then
						ignore 'identical' "$filename"
					fi
					continue
				fi
			else
				# $local does not symlink to $remote
				if [[ -d $local && -d $remote && ! -L $remote ]]; then
					# $remote is a real directory while
					# $local is a directory or a symlinked directory
					# we do not take any action regardless of which it is.
					if $VERBOSE; then
						ignore 'identical' "$filename"
					fi
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
	# Fetch the repo files and redirect the output into file descriptor 3
	done 3< <(get_repo_files "$repo")
	return $EX_SUCCESS
}

# Fetches all files and folders in a repository that are tracked by git
# Works recursively on submodules as well
function get_repo_files {
	# Resolve symbolic links
	# e.g. on osx $TMPDIR is in /var/folders...
	# which is actually /private/var/folders...
	# We do this so that the root part of $toplevel can be replaced
	# git resolves symbolic links before it outputs $toplevel
	local root=$(cd "$1"; pwd -P)
	(
		local path
		while IFS= read -d $'\n' -r path; do
			# Remove quotes from ls-files
			# (used when there are newlines in the path)
			path=${path/#\"/}
			path=${path/%\"/}
			# Check if home/ is a submodule
			[[ $path == 'home' ]] && continue
			# Remove the home/ part
			path=${path/#home\//}
			# Print the file path (NUL separated because \n can be used in filenames)
			printf "$path\0"
			# Get the path of all the parent directories
			# up to the repo root.
			while true; do
				path=$(dirname "$path")
				# If path is '.' we're done
				[[ $path == '.' ]] && break
				# Print the path
				printf "$path\0"
			done
		# Enter the repo, list the repo root files in home
		# and do the same for any submodules
		done < <(cd "$root" &&
		         git ls-files 'home/' &&
		         git submodule --quiet foreach --recursive \
		         "$homeshick/lib/submodule_files.sh \"$root\" \"\$toplevel\" \"\$path\"")
		# Unfortunately we have to use an external script for `git submodule foreach'
		# because versions prior to ~ 2.0 use `eval' to execute the argument.
		# This somehow messes quite badly with string substitution.
	) | sort -zu # sort the results and make the list unique (-u), NUL is the line separator (-z)
}
