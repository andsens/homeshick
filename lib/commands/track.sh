#!/bin/bash

function track {
	[[ ! $1 || ! $2 ]] && help track
	local castle=$1
	local filename
	filename=$(abs_path "$2")
	if [[ $filename != $HOME/* ]]; then
		err "$EX_ERR" "The file $filename must be in your home directory."
	fi
	# If the file is a dead symlink, we track it anyhow, hence the '! -L'
	if [[ ! -e $filename && ! -L $filename ]]; then
		err "$EX_ERR" "The file $filename does not exist."
	fi
	home_exists 'track' "$castle"

	local files_to_track
	files_to_track=$(find "$filename" -name .git -prune -o -not -type d -print)
	if [[ -z $files_to_track ]]; then
		ignore 'track' 'No files to track'
		return "$EX_SUCCESS"
	fi

	# check-ignore was only added in 1.8.2
	local check_ignore=false
	version_compare "$GIT_VERSION" 1.8.2
	[[ $? != 2 ]] && check_ignore=true

	# repos is a global variable
	# shellcheck disable=SC2154
	local repo="$repos/$castle"
	oldIFS=$IFS
	IFS=$'\n'
	for homepath in $files_to_track; do
		IFS=$oldIFS

		local relpath=${homepath#$HOME/}
		pending 'track' "$relpath"
		local relpath_in_repo="home/$relpath"
		local repopath="$repo/$relpath_in_repo"

		if [[ -e $repopath ]]; then
			ignore 'exists' "The file $relpath is already being tracked."
			continue
		fi
		if $check_ignore; then
			if (cd "$repo" && git check-ignore --quiet "$relpath_in_repo") then
				ignore 'ignored' "The file $relpath would be ignored by git."
				continue
			fi
		fi

		if [[ -e $repopath && $FORCE = false ]]; then
			continue
			prompt_no 'conflict' "$repopath exists" "overwrite?" || continue
		fi
		local remote_folder
		remote_folder=$(dirname "$repopath")
		mkdir -p "$remote_folder"

		# Check if the file is a relative symlink, if so we don't move it but create
		# an appropriate relative symlink instead that matches the new location
		if [[ -L $homepath ]]; then
			local target
			target=$(readlink "$homepath")
			if [[ $target =~ ^/ ]]; then
				# It's an absolute symlink, just move it
				mv -f "$homepath" "$repopath"
			else
				# Figure out the relative path from the symlink location in
				# the castle to the path the symlink points at

				# Convert the relative target into an absolute one
				local abs_target
				local target_dir
				target_dir=$(abs_path "$(dirname "$homepath")")
				abs_target=$(clean_path "$target_dir/$target")
				# Get the relative path from the repopath dir to the target
				local rel_targetpath
				rel_targetpath=$(create_rel_path "$(dirname "$repopath")/" "$abs_target") || return $?
				ln -s "$rel_targetpath" "$repopath"
				# Remove $homepath so we can create the symlink further down
				rm "$homepath"
			fi
		else
			# Just a regular old file. Move it
			mv -f "$homepath" "$repopath"
		fi
		# Create the symlink in place of the moved file (simulate what the link command does)
		local rel_repopath
		rel_repopath=$(create_rel_path "$(dirname "$homepath")/" "$repopath") || return $?
		ln -s "$rel_repopath" "$homepath"

		local git_out
		git_out=$(cd "$repo" && git add "$relpath_in_repo" 2>&1)
		status=$?
		if [[ $status == 128 && $check_ignore == false ]]; then
			# Currently our only option with git < 1.8.2, we can't be sure some other error hasn't occurred
			ignore 'ignored' "The file $relpath would be ignored by git."
			mv -f "$repopath" "$homepath"
			continue
		elif [[ $status != 0 ]]; then
			fail 'track' "Unable to add file to git. Git says: $git_out"
			exit
		fi
		success
	done
	return "$EX_SUCCESS"
}
