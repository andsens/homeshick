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
	for remote in $(find "$repo/home" -mindepth 1 -name .git -prune -o -print); do
		IFS=$oldIFS
		filename=${remote#$repo/home/}
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

function castle_exists {
	local action=$1
	local castle=$2
	local repo="$repos/$castle"
	if [[ ! -d $repo ]]; then
		err $EX_ERR "Could not $action $castle, expected $repo to exist"
	fi
}

function home_exists {
	local action=$1
	local castle=$2
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		err $EX_ERR "Could not $action $castle, expected $repo to contain a home folder"
	fi
}

function abs_path {
	local dir=$(dirname "$1")
	local base=$(basename "$1")
	(cd "$dir" &>/dev/null; printf "%s/%s" "$(pwd)" "$base")
}
