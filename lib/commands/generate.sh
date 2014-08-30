#!/bin/bash

function generate {
	[[ ! $1 ]] && help_err generate
	local castle=$1
	local repo="$repos/$castle"
	pending 'generate' "$castle"
	if [[ -d $repo ]]; then
		err $EX_ERR "The castle $castle already exists"
	fi

	mkdir "$repo"
	local git_out
	git_out=$(cd "$repo"; git init 2>&1)
	[[ $? == 0 ]] || err $EX_SOFTWARE "Unable to initialize repository $repo. Git says:" "$git_out"
	mkdir "$repo/home"
	success
	return $EX_SUCCESS
}
