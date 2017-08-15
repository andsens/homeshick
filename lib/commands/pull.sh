#!/bin/bash

function pull {
	[[ ! $1 ]] && help_err pull
	local castle=$1
	# repos is a global variable
	# shellcheck disable=SC2154
	local repo="$repos/$castle"
	pending 'pull' "$castle"
	castle_exists 'pull' "$castle"
	if ! repo_has_upstream "$repo"; then
		ignore 'no upstream' "Could not pull $castle, it has no upstream"
		return "$EX_SUCCESS"
	fi

	local git_out
	git_out=$(cd "$repo" && git pull 2>&1) || \
		err "$EX_SOFTWARE" "Unable to pull $repo. Git says:" "$git_out"

	version_compare "$GIT_VERSION" 1.6.5
	if [[ $? != 2 ]]; then
		git_out=$(cd "$repo" && git submodule update --recursive --init 2>&1) || \
			err "$EX_SOFTWARE" "Unable update submodules for $repo. Git says:" "$git_out"
	else
		git_out=$(cd "$repo" && git submodule update --init 2>&1) || \
			err "$EX_SOFTWARE" "Unable update submodules for $repo. Git says:" "$git_out"
	fi
	success
	return "$EX_SUCCESS"
}

function symlink_new_files {
	local updated_castles=()
	while [[ $# -gt 0 ]]; do
		local castle=$1
		shift
		local repo="$repos/$castle"
		if [[ ! -d $repo/home ]]; then
			continue;
		fi
		local git_out
		local now
		now=$(date +%s)
		if ! git_out=$(cd "$repo" && git diff --name-only --diff-filter=A "HEAD@{(($now-$T_START+1)).seconds.ago}" HEAD -- home 2>/dev/null | wc -l 2>&1); then
			continue  # Ignore errors, this operation is not mission critical
		fi
		if [[ $git_out -gt 0 ]]; then
			updated_castles+=("$castle")
		fi
	done
	ask_symlink "${updated_castles[@]}"
	return "$EX_SUCCESS"
}
