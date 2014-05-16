#!/bin/bash

function track {
	[[ ! $1 || ! $2 ]] && help track
	local castle=$1
	local filename=$(abs_path "$2")
	if [[ $filename != $HOME/* ]]; then
		err $EX_ERR "The file $filename must be in your home directory."
	fi
	if [[ ! -e $filename ]]; then
		err $EX_ERR "The file $filename does not exist."
	fi
	home_exists 'track' "$castle"

	local files_to_track=$(find "$filename" -name .git -prune -o -not -type d -print)
	if [[ -z $files_to_track ]]; then
		ignore 'track' 'No files to track'
		return $EX_SUCCESS
	fi

	# check-ignore was only added in 1.8.2
	local check_ignore=false
	version_compare $GIT_VERSION 1.8.2
	[[ $? != 2 ]] && check_ignore=true

	local repo="$repos/$castle"
	oldIFS=$IFS
	IFS=$'\n'
	for local in $files_to_track; do
		IFS=$oldIFS

		local filepath=${local#$HOME/}
		pending 'track' "$filepath"
		local rel_remote="home/$filepath"
		local remote="$repo/$rel_remote"

		if [[ -e $remote ]]; then
			ignore 'exists' "The file $filepath is already being tracked."
			continue
		fi
		if $check_ignore; then
			(cd "$repo"; git check-ignore --quiet "$rel_remote")
			if [[ $? == 0 ]]; then
				ignore 'ignored' "The file $filepath would be ignored by git."
				continue
			fi
		fi

		if [[ -e $remote && $FORCE = false ]]; then
			continue
			prompt_no 'conflict' "$remote exists" "overwrite?" || continue
		fi
		local remote_folder=$(dirname "$remote")
		mkdir -p "$remote_folder"
		mv -f "$local" "$remote"
		ln -s "$remote" "$local"

		local git_out
		git_out=$(cd "$repo"; git add "$rel_remote" 2>&1)
		status=$?
		if [[ $status == 128 && $check_ignore == false ]]; then
			# Currently our only option with git < 1.8.2, we can't be sure some other error hasn't occurred
			ignore 'ignored' "The file $filepath would be ignored by git."
			mv -f "$remote" "$local"
			continue
		elif [[ $status != 0 ]]; then
			fail 'track' "Unable to add file to git. Git says: $git_out"
			exit
		fi
		success
	done
	return $EX_SUCCESS
}
