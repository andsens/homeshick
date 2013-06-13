#!/bin/bash

function symlink {
	[[ ! $1 ]] && help symlink
	local castle=$1
	castle_exists $castle
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		ignore 'ignored' "$castle"
		return $EX_SUCCESS
	fi
	for filepath in $(find $repo/home -mindepth 1); do
		file=${filepath#$repo/home/}

		if [[ -d $repo/home/$file && -d $HOME/$file ]]; then
			if [[ -L $HOME/$file && $(readlink "$HOME/$file") == $repo/home/$file ]]; then
				# Legacy handling for when we used to symlink directories
				rm $HOME/$file
			else
				continue
			fi
		fi

		if [[ -e $HOME/$file && $(readlink "$HOME/$file") == $repo/home/$file ]]; then
			ignore 'identical' $file
			continue
		fi

		if [[ -e $HOME/$file || -L $HOME/$file ]]; then
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
			rm -rf "$HOME/$file"
		fi

		if [[ -d $repo/home/$file && ! -L $repo/home/$file ]]; then
			pending $bldblu 'directory' $file
			mkdir $HOME/$file
		else
			pending 'symlink' $file
			ln -s $repo/home/$file $HOME/$file
		fi

		success
	done
	return $EX_SUCCESS
}

function track {
	[[ ! $1 || ! $2 ]] && help track
	local castle=$1
	local filename=$(abs_path $2)
	if [[ $filename != $HOME/* ]]; then
		err $EX_ERR "The file $filename must be in your home directory."
	fi
	if [[ $filename == $repos/* ]]; then
		err $EX_ERR "The file $filename is already being tracked."
	fi

	local repo="$repos/$castle"
	local newfile="$repo/home/${filename#$HOME/}"
	pending "symlink" "$newfile to $filename"
	home_exists 'track' $castle
	if [[ ! -e $filename ]]; then
		err $EX_ERR "The file $filename does not exist."
	fi
	if [[ -e $newfile && $FORCE = false ]]; then
		err $EX_ERR "The file $filename already exists in the castle $castle."
	fi
	if [[ ! -f $filename ]]; then
		err $EX_ERR "The file $filename must be a regular file."
	fi
	mkdir -p $(dirname $newfile)
	mv -f "$filename" "$newfile"
	ln -s "$newfile" "$filename"
	(cd $repo; git add "$newfile")
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

function abs_path {
	(cd "${1%/*}" &>/dev/null; printf "%s/%s" "$(pwd)" "${1##*/}")
}
