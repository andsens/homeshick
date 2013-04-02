#!/bin/bash

# Get the repo name from an URL
function parse_url {
	local regexp_extended_flag='r'
	local system=$(uname -a)
	if [[ $system =~ Darwin && ! $system =~ AppleTV ]]; then
		regexp_extended_flag='E'
	fi
	printf -- "$1" | sed -$regexp_extended_flag 's#^.*/([^/.]+)(\.git)?$#\1#'
}

function clone {
	[[ -z $1 ]] && help clone
	local repo_path="$repos/$(parse_url $1)"
	test -e $repo_path && die "      $bldblu exists$txtdef $repo_path"
	local git_repo=$1
	if [[ $git_repo =~ ^([A-Za-z_-]+\/[A-Za-z_-]+)$ ]]; then
		git_repo="git://github.com/$1.git"
	fi

	local git_version=$(git --version | grep -oE '([0-9]+.?){3}')

	local git_out
	pending 'clone' $git_repo
	if [[ $(version_compare $git_version 1.6.5) -ge 0 ]]; then
		git_out=$(git clone --recursive $git_repo $repo_path 2>&1)
		[[ $? == 0 ]] || err "Unable to clone $git_repo. Git says:" "$git_out"
		success
	else
		git_out=$(git clone $git_repo $repo_path 2>&1)
		[[ $? == 0 ]] || err "Unable to clone $git_repo. Git says:" "$git_out"
		success

		pending 'submodules' $git_repo
		git_out=$(cd $repo_path; git submodule update --init 2>&1)
		[[ $? == 0 ]] || err "Unable to clone submodules for $git_repo. Git says:" "$git_out"
		success
	fi
}

function generate {
	[[ -z $1 ]] && help generate
	local repo=$1
	pending 'generate' "$repo"
	mkdir -p "$repo"
	local git_out
	git_out=$(cd $repo; git init 2>&1)
	[[ $? == 0 ]] || err "Unable to initialize repository $repo. Git says:" "$git_out"
	mkdir -p "$repo/home"
	success
}

function pull {
	[[ -z $1 ]] && help pull
	local repo="$repos/$1"
	castle_exists 'pull' $1
	pending 'pull' $1

	local git_out
	git_out=$(cd $repo; git pull 2>&1)
	[[ $? == 0 ]] || err "Unable to pull $repo. Git says:" "$git_out"

	local git_version=$(git --version | grep -oE '([0-9]+.?){3}')
	if [[ $(version_compare $git_version 1.6.5) -ge 0 ]]; then
		git_out=$(cd $repo; git submodule update --recursive --init 2>&1)
		[[ $? == 0 ]] || err "Unable update submodules for $repo. Git says:" "$git_out"
	else
		git_out=$(cd $repo; git submodule update --init 2>&1)
		[[ $? == 0 ]] || err "Unable update submodules for $repo. Git says:" "$git_out"
	fi
	success
}

function list {
	for repo in $(find $repos -mindepth 2 -maxdepth 2 -name .git -type d | sed 's#/.git$##g'); do
		local remote_url=$(cd $repo; git config remote.origin.url)
		local reponame=$(basename $repo)
		info $reponame $remote_url
	done
}

function list_castle_names {
	for repo in $(find $repos -mindepth 2 -maxdepth 2 -name .git -type d | sed 's#/.git$##g'); do
		local reponame=$(basename $repo)
		printf "$reponame\n"
	done
}

function check {
	[[ -z $1 ]] && help check
	local repo="$repos/$1"
	castle_exists 'check' $1
	pending 'checking' $1
	local ref=$(cd $repo; git symbolic-ref HEAD 2>/dev/null)
	local remote_url=$(cd $repo; git config remote.origin.url 2>/dev/null)
	local remote_head=$(git ls-remote -q --heads "$remote_url" "$ref" 2>/dev/null | cut -f 1)
	if [[ -n $remote_head ]]; then
		local local_head=$(cd $repo; git rev-parse HEAD)
		if [[ $remote_head == $local_head ]]; then
			success 'up to date'
		else
			(cd $repo; git branch --contains "$remote_head" 2>/dev/null) > /dev/null
			if [[ $? == 0 ]]; then
				fail 'ahead'
			else
				fail 'behind'
			fi
		fi
	else
		ignore 'uncheckable'
	fi
}

function symlink_cloned_files {
	local cloned_castles=()
	while [[ $# -gt 0 ]]; do
		local castle=$(parse_url $1)
		shift
		local repo="$repos/$castle"
		if [[ $(find $repo -maxdepth 1 -mindepth 1 | wc -l) > 0 ]]; then
			cloned_castles+=($castle)
		fi
	done
	ask_symlink ${cloned_castles[*]}
}

function symlink_new_files {
	local updated_castles=()
	while [[ $# -gt 0 ]]; do
		local castle=$1
		shift
		local repo="$repos/$castle"
		local git_out
		local now=$(date +%s)
		git_out=$(cd $repo; git diff --name-only --diff-filter=A HEAD@{$[$now-$T_START+1].seconds.ago} HEAD 2>/dev/null | wc -l 2>&1)
		[[ $? == 0 ]] || continue # Ignore errors, this operation is not mission critical
		if [[ $git_out > 0 ]]; then
			updated_castles+=($castle)
		fi
	done
	ask_symlink ${updated_castles[*]}
}

function ask_symlink {
	if [[ $# > 0 ]]; then
		if [[ $# = 1 ]]; then
			info 'updates' "The castle $1 has new files."
		else
			OIFS=$IFS
			IFS=,
			info 'updates' "The castles $* have new files."
			IFS=$OIFS
		fi
		prompt "Symlink? [yN]"
		if [[ $? = 0 ]]; then
			for castle in $*; do
				symlink $castle
			done
		fi
	fi
}

# Snatched from http://rubinium.org/blog/archives/2010/04/05/shell-script-version-compare-vercmp/
function version_compare {
	expr '(' "$1" : '\([^.]*\)' ')' '-' '(' "$2" : '\([^.]*\)' ')' '|' \
		'(' "$1.0" : '[^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0" : '[^.]*[.]\([^.]*\)' ')' '|' \
		'(' "$1.0.0" : '[^.]*[.][^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0.0" : '[^.]*[.][^.]*[.]\([^.]*\)' ')' '|' \
		'(' "$1.0.0.0" : '[^.]*[.][^.]*[.][^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0.0.0" : '[^.]*[.][^.]*[.][^.]*[.]\([^.]*\)' ')'
}
