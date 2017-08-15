#!/bin/bash

function castle_exists {
	local action=$1
	local castle=$2
	# repos is a global variable, disable SC2154
	# shellcheck disable=SC2154
	local repo="$repos/$castle"
	if [[ ! -d $repo ]]; then
		err "$EX_ERR" "Could not $action $castle, expected $repo to exist"
	fi
}

function home_exists {
	local action=$1
	local castle=$2
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		err "$EX_ERR" "Could not $action $castle, expected $repo to contain a home folder"
	fi
}

function list_castle_names {
	while IFS= read -d $'\0' -r repo ; do
		local reponame
		reponame=$(basename "${repo%/.git}")
		printf "%s\n" "$reponame"
	done < <(find -L "$repos" -mindepth 2 -maxdepth 2 -name .git -type d -print0 | sort -z)
	return "$EX_SUCCESS"
}

function abs_path {
	local dir
	local base
	dir=$(dirname "$1")
	base=$(basename "$1")
	(cd "$dir" &>/dev/null || return $?; printf "%s/%s" "$PWD" "$base")
}
