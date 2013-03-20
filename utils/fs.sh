#!/bin/bash

function symlink {
	[[ -z $1 ]] && help symlink
	castle_exists 'symlink' $1
	local repo="$repos/$1/home"
	local direrrors=''
	for filepath in $(find $repo -mindepth 1 -maxdepth 1); do
		file=$(basename $filepath)
		if [[ -e $HOME/$file && $(readlink "$HOME/$file") == $repo/$file ]]; then
			status $bldblu 'identical' $file
			continue
		fi

		if [[ -e $HOME/$file || -L $HOME/$file ]]; then
			if $SKIP; then
				status $bldblu 'exists' $file
				continue
			fi
			if ! $FORCE; then
				status $bldred 'conflict' "$file exists"
				prompt "Overwrite $file? [yN]"
				if [[ $? != 0 ]]; then
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
	if [[ -n $direrrors && $FORCE = false ]]; then
		printf "\nThe following directories already exist and will only\n" >&2
		printf "be overwritten, if you delete or move them manually:\n" >&2
		printf "$direrrors\n" >&2
	fi
}

function track {
	[[ -z $1 || -z $2 ]] && help track
	castle_exists 'track' $1
	local repo="$repos/$1/home"
	local newfile="$repo/$2"
	if [[ ! -e $2 ]]; then
		err "The file $2 does not exist."
	fi
	if [[ -e $newfile && $FORCE = false ]]; then
		err "The file $2 already exists in the castle $1."
	fi
	pending "symlink" "$newfile to $2"
	if ! $FORCE; then
		mv "$2" "$newfile"
		ln -s "$newfile" $2
	else
		mv -f "$2" "$newfile"
		ln -sf "$newfile" $2
	fi
	success
}

function castle_exists {
	local repo="$repos/$2/home"
	if [[ ! -d $repo ]]; then
		err "Could not $1 $2, expected $repo to exist and contain dotfiles"
	fi
}
