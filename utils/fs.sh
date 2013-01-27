#!/bin/bash

function symlink {
	if [[ -z "$1" ]]; then
		die "homeshick symlink requires at least 1 argument: \"homeshick symlink NAME\"."
	fi
	castle_exists 'symlink' $1
	local repo="$repos/$1/home"
	local direrrors=''
	for filepath in `find $repo -mindepth 1 -maxdepth 1`; do
		file=`basename $filepath`
		if [[ -e $HOME/$file && `readlink "$HOME/$file"` == "$repo/$file" ]]; then
			status $bldblu 'identical' $file
			continue
		fi
		
		if [ -e $HOME/$file ]; then
			if [ -n "$B_SKIP" ]; then
				status $bldblu 'exists' $file
				continue
			fi
			if [ -z "$B_FORCE" ]; then
				status $bldred 'conflict' "$file exists"
				read -p "Overwrite $file? [yN]" overwrite
				if [[ ! $overwrite =~ [Yy] ]]; then
					continue
				fi
			fi
			pending 'overwrite' $file
			rm -rf "$HOME/$file"
		else
			pending 'symlink' $file
		fi
		
		ln -s $repo/$file $HOME/$file
		success
	done
	if [[ -n "$direrrors" && -z "$B_FORCE" ]]; then
		printf "\nThe following directories already exist and will only\n" >&2
		printf "be overwritten, if you delete or move them manually:\n" >&2
		printf "$direrrors\n" >&2
	fi
}

function track {
	if [[ -z "$1" || -z "$2" ]]; then
		die "homeshick track requires at least 2 arguments: \"homeshick track FILE CASTLE\"."
	fi
	castle_exists 'track' $2
	local repo="$repos/$2/home"
	local newfile="$repo/$1"
	if [[ ! -e "$1" ]]; then
		err "The file $1 does not exist."
	fi
	if [[ -e "$newfile" && -z "$B_FORCE" ]]; then
		err "The file $1 already exists in the castle $2."
	fi
	pending "symlink" "$newfile to $1"
	if [ -z "$B_FORCE" ]; then
		mv "$1" "$newfile"
		ln -s "$newfile" $1
	else
		mv -f "$1" "$newfile"
		ln -sf "$newfile" $1
	fi
	success
}

function castle_exists {
	local repo="$repos/$2/home"
	if [[ ! -d "$repo" ]]; then
		err "Could not $1 $2, expected $repo to exist and contain dotfiles"
	fi
}
