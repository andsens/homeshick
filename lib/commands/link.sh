#!/bin/bash

function symlink {
	[[ ! $1 ]] && help symlink
	local castle=$1
	castle_exists 'link' "$castle"
	# repos is a global variable
	# shellcheck disable=SC2154
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		ignore 'ignored' "$castle"
		return "$EX_SUCCESS"
	fi
	# Run through the repo files using process substitution.
	# The get_repo_files call is at the bottom of this loop.
	# We set the IFS to nothing and the separator for `read' to NUL so that we
	# don't separate files with newlines in their name into two iterations.
	# `read's stdin comes from a third unused file descriptor because we are
	# using the real stdin for prompting the user whether he wants to overwrite or skip
	# on conflicts.
	while IFS= read -d $'\0' -r filename <&3 ; do
		local remote="$repo/home/$filename"
		local local="$HOME/$filename"
		local rel_remote
		rel_remote=$(create_rel_path "$(dirname "$local")" "$remote")

		if [[ -e $local || -L $local ]]; then
			# $local exists (but may be a dead symlink)
			if [[ -L $local && $(readlink "$local") == "$rel_remote" ]]; then
				# $local symlinks to $remote.
				if $VERBOSE; then
					ignore 'identical' "$filename"
				fi
				continue
			elif [[ $(readlink "$local") == "$remote" ]]; then
				# $local is an absolute symlink to $remote
				if [[ -d $remote && ! -L $remote ]]; then
					# $remote is a directory, but $local is a symlink -> legacy handling.
					rm "$local"
				else
					# replace it with a relative symlink
					rm "$local"
				fi
			else
				# $local does not symlink to $remote
				# check if we should delete $local
				if [[ -d $local && -d $remote && ! -L $remote ]]; then
					# $remote is a real directory while
					# $local is a directory or a symlinked directory
					# we do not take any action regardless of which it is.
					if $VERBOSE; then
						ignore 'identical' "$filename"
					fi
					continue
				elif $SKIP; then
					ignore 'exists' "$filename"
					continue
				elif ! $FORCE; then
					prompt_no 'conflict' "$filename exists" "overwrite?" || continue
				fi
				# Delete $local.
				rm -rf "$local"
			fi
		fi

		if [[ ! -d $remote || -L $remote ]]; then
			# $remote is not a real directory so we create a symlink to it
			pending 'symlink' "$filename"
			ln -s "$rel_remote" "$local"
		else
			pending 'directory' "$filename"
			mkdir "$local"
		fi

		success
	# Fetch the repo files and redirect the output into file descriptor 3
	done 3< <(get_repo_files "$repo")
	return "$EX_SUCCESS"
}

# Fetches all files and folders in a repository that are tracked by git
# Works recursively on submodules as well
# Disable SC2154, we cannot do it inline where $homeshick is used.
# shellcheck disable=SC2154
function get_repo_files {
	# Resolve symbolic links
	# e.g. on osx $TMPDIR is in /var/folders...
	# which is actually /private/var/folders...
	# We do this so that the root part of $toplevel can be replaced
	# git resolves symbolic links before it outputs $toplevel
	local root
	root=$(cd "$1" && pwd -P)
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
			# Disable SC2059, using %s messes with the filename
			# shellcheck disable=SC2059
			printf "$path\0"
			# Get the path of all the parent directories
			# up to the repo root.
			while true; do
				path=$(dirname "$path")
				# If path is '.' we're done
				[[ $path == '.' ]] && break
				# Print the path
				# shellcheck disable=SC2059
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
