#!/bin/bash

function push {
	[[ ! $1 ]] && help_err push
	local castle=$1
	local repo="$repos/$castle"
	pending 'push' $castle
	castle_exists 'push' $castle

	$(repo_has_upstream $repo)
	if [[ $? != 0 ]]; then
		ignore 'no upstream' "Could not push $castle, it has no upstream"
		return $EX_SUCCESS
	fi

	local git_out
	git_out=$(cd "$repo"; git push 2>&1)
	[[ $? == 0 ]] || err $EX_SOFTWARE "Unable to push $repo. Git says:" "$git_out"

	success
	return $EX_SUCCESS
}
