#!/bin/bash

# Snatched from http://stackoverflow.com/questions/4023830/bash-how-compare-two-strings-in-version-format 
function version_compare {
	if [[ $1 == $2 ]]; then
		return 0
	fi
	local IFS=.
	local i ver1=($1) ver2=($2)
	# fill empty fields in ver1 with zeros
	for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
		ver1[i]=0
	done
	for ((i=0; i<${#ver1[@]}; i++)); do
		if [[ -z ${ver2[i]} ]]; then
			# fill empty fields in ver2 with zeros
			ver2[i]=0
		fi
		if ((10#${ver1[i]} > 10#${ver2[i]})); then
			return 1
		fi
		if ((10#${ver1[i]} < 10#${ver2[i]})); then
			return 2
		fi
	done
	return 0
}

function repo_has_upstream {
	local repo=$1

	# Check if the castle has an upstream remote
	# Fetch the current branch name
	local ref=$(cd "$repo"; git symbolic-ref HEAD 2>/dev/null)
	local branch=${ref#refs/heads/}
	# Get the upstream remote of that branch
	local remote_name=$(cd "$repo"; git config branch.$branch.remote 2>/dev/null)
	if [[ -z $remote_name ]]; then
		return $EX_ERR
	fi
	return $EX_SUCCESS
}
