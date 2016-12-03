#!/bin/bash

function check {
	local exit_status=$EX_SUCCESS
	[[ ! $1 ]] && help_err check
	local castle=$1
	local repo="$repos/$castle"
	pending 'checking' "$castle"
	castle_exists 'check' "$castle"

	# Fetch the current branch name
	local ref=$(cd "$repo"; git symbolic-ref HEAD 2>/dev/null)
	local branch=${ref#refs/heads/}
	# Get the upstream remote of that branch
	local remote_name=$(cd "$repo"; git config branch.$branch.remote 2>/dev/null)
	local remote_url=$(cd "$repo"; git config remote.$remote_name.url 2>/dev/null)
	# Get the HEAD of the current branch on the upstream remote
	local remote_head=$(git ls-remote --heads "$remote_url" "$branch" 2>/dev/null | cut -f 1)
	if [[ $remote_head ]]; then
		local local_head=$(cd "$repo"; git rev-parse HEAD)
		if [[ $remote_head == $local_head ]]; then
			git_status=$(cd "$repo"; git status --porcelain 2>/dev/null)
			if [[ -z $git_status ]]; then
				success 'up to date'
				exit_status=$EX_SUCCESS
			else
				fail 'modified'
				exit_status=$EX_MODIFIED
			fi
		else
			local merge_base=$(cd "$repo"; git merge-base "$remote_head" "$local_head" 2>/dev/null)
			local checked_ref
			checked_ref=$(cd "$repo"; git rev-parse --verify "$remote_head" 2>/dev/null)
			if [[ $? == 0 && $merge_base != "" && $merge_base == $checked_ref ]]; then
				fail 'ahead'
				exit_status=$EX_AHEAD
			else
				fail 'behind'
				exit_status=$EX_BEHIND
			fi
		fi
	else
		ignore 'uncheckable'
		exit_status=$EX_UNAVAILABLE
	fi
	return $exit_status
}
