#!/bin/bash

# Get the repo name from an URL
function parse_url {
	local regexp_extended_flag='r'
	local system=`uname -a`
	if [[ $system =~ "Darwin" && ! $system =~ "AppleTV" ]]; then
		regexp_extended_flag='E'
	fi
	printf -- "$1" | sed -$regexp_extended_flag 's#^.*/([^/.]+)(\.git)?$#\1#'
}

function clone {
	[ -z "$1" ] && help clone
	local repo_path="$repos/`parse_url $1`"
	test -e $repo_path && die "      $bldblu exists$txtdef $repo_path"
	local git_repo=$1
	if [[ $git_repo =~ ^([A-Za-z_-]+\/[A-Za-z_-]+)$ ]]; then
		git_repo="git://github.com/$1.git"
	fi
	
	local git_version=`git --version | grep -oE '([0-9]+.?){3}'`
	
	pending 'clone' $git_repo
	if [ "$(version_compare $git_version 1.6.5)" -ge '0' ]; then
		git clone --quiet --recursive $git_repo $repo_path
		success
	else
		git clone --quiet $git_repo $repo_path
		if [ $? != 0 ]; then
			err "Unable to clone $git_repo"
		fi
		success
		
		pending 'submodules' $git_repo
		(cd $repo_path; git submodule --quiet update --init)
		success
	fi
}

function generate {
	[ -z "$1" ] && help generate
	local repo=$1
	pending 'generate' "$repo"
	mkdir -p "$repo"
	(cd $1; git init --quiet)
	mkdir -p "$repo/home"
	success
}

function pull {
	[ -z "$1" ] && help pull
	local repo="$repos/$1"
	castle_exists 'pull' $1
	pending 'pull' $1
	(cd $repo; git pull --quiet)
	local git_version=`git --version | grep -oE '([0-9]+.?){3}'`
	if [ "$(version_compare $git_version 1.6.5)" -ge '0' ]; then
		(cd $repo; git submodule --quiet update --recursive --init)
	else
		(cd $repo; git submodule --quiet update --init)
	fi
	success
}

function list {
	if [ `(find $repos -type d; find $repos -type l)  | wc -l` -lt 2 ]; then
		err "No castles exist for homeshick in: $repos"
	fi
	for repo in `find $repos -mindepth 2 -maxdepth 2 -name .git -type d | sed 's#/.git$##g'`; do
		local remote_url=$(cd $repo; git config remote.origin.url)
		local reponame=`basename $repo`
		status $bldblu $reponame $remote_url
	done
}

function list_castle_names {
	for repo in `find $repos -mindepth 2 -maxdepth 2 -name .git -type d | sed 's#/.git$##g'`; do
		local reponame=`basename $repo`
		printf "$reponame\n"
	done
}

function check {
	[ -z "$1" ] && help check
	local repo="$repos/$1"
	castle_exists 'check' $1
	pending 'checking' $1
	local ref=$(cd $repo; git symbolic-ref HEAD 2>/dev/null)
	local remote_url=$(cd $repo; git config remote.origin.url 2>/dev/null)
	local remote_head=$(git ls-remote -q --heads "$remote_url" "$ref" 2>/dev/null | cut -f 1)
	if [ -n "$remote_head" ]; then
		local local_head=$(cd $repo; git rev-parse HEAD)
		if [ "$remote_head" == "$local_head" ]; then
			success 'up to date'
		else
			(cd $repo; git branch --contains "$remote_head" 2>/dev/null) > /dev/null
			if [ "$?" == "0" ]; then
				fail 'ahead'
			else
				fail 'behind'
			fi
		fi
	else
		ignore 'uncheckable'
	fi
}

# Snatched from http://rubinium.org/blog/archives/2010/04/05/shell-script-version-compare-vercmp/
function version_compare {
	expr '(' "$1" : '\([^.]*\)' ')' '-' '(' "$2" : '\([^.]*\)' ')' '|' \
		'(' "$1.0" : '[^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0" : '[^.]*[.]\([^.]*\)' ')' '|' \
		'(' "$1.0.0" : '[^.]*[.][^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0.0" : '[^.]*[.][^.]*[.]\([^.]*\)' ')' '|' \
		'(' "$1.0.0.0" : '[^.]*[.][^.]*[.][^.]*[.]\([^.]*\)' ')' '-' '(' "$2.0.0.0" : '[^.]*[.][^.]*[.][^.]*[.]\([^.]*\)' ')'
}
