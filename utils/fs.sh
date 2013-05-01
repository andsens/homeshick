#!/bin/bash

function symlink {
	[[ ! $1 ]] && help symlink
	local castle=$1
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		ignore 'ignored' "$castle"
		return $EX_SUCCESS
	fi
	for filepath in $(find $repo/home -mindepth 1); do
		file=${filepath#$repo/home/}
		if [[ -e $HOME/$file && $(readlink "$HOME/$file") == $repo/home/$file ]]; then
			ignore 'identical' $file
			continue
		fi

		if [[ -e $HOME/$file || -L $HOME/$file ]]; then
			if [[ -d $repo/home/$file && -d $HOME/$file ]]; then
				continue
			fi
			if $SKIP; then
				ignore 'exists' $file
				continue
			fi
			if ! $FORCE; then
				prompt_no 'conflict' "$file exists" "overwrite?"
				if [[ $? != 0 ]]; then
					continue
				fi
			fi
			pending 'overwrite' $file
			rm -rf "$HOME/$file"
		else
			if [[ -d $repo/home/$file ]]; then
				pending 'directory' $file
			else
				pending 'symlink' $file
			fi
		fi

		if [[ -d $repo/home/$file ]]; then
			mkdir -p $HOME/$file
		else
			ln -s $repo/home/$file $HOME/$file
		fi
		success
	done
	return $EX_SUCCESS
}

function track {
	[[ ! $1 || ! $2 ]] && help track
	local castle=$1
	local filename=$2
	local repo="$repos/$castle"
	local newfile="$repo/home/$filename"
	pending "symlink" "$newfile to $filename"
	home_exists 'track' $castle
	if [[ ! -e $filename ]]; then
		err $EX_ERR "The file $filename does not exist."
	fi
	if [[ -e $newfile && $FORCE = false ]]; then
		err $EX_ERR "The file $filename already exists in the castle $castle."
	fi
	if ! $FORCE; then
		mv "$filename" "$newfile"
		ln -s "$newfile" $filename
	else
		mv -f "$filename" "$newfile"
		ln -sf "$newfile" $filename
	fi
	success
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
