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
	local repo_path="$repos/`parse_url $1`"
	test -e $repo_path && die "     $bldblu exists $txtdef $repo_path"
	local git_repo=$1
	if [[ $git_repo =~ ^([A-Za-z_-]+\/[A-Za-z_-]+)$ ]]; then
		git_repo="git://github.com/$1.git"
	fi
	pending 'clone' $git_repo
	if [ -z "$B_PRETEND" ]; then
		git clone --quiet $git_repo $repo_path
		if [ $? != 0 ]; then
			err "Unable to clone $git_repo"
		fi
	fi
	success
	pending 'submodules' $git_repo
	if [ -z "$B_PRETEND" ]; then
		(cd $repo_path; git submodule --quiet update --init)
	fi
	success
}

function generate {
	pending 'generate' $1
	if [ -z "$B_PRETEND" ]; then
		mkdir -p $1
		(cd $1; git init --quiet)
		mkdir -p home
	fi
	success
}

function pull {
	local repo="$repos/$1"
	castle_exists 'pull' $1
	pending 'pull' $1
	if [ -z "$B_PRETEND" ]; then
		(cd $repo;
			git pull --quiet;
			git submodule --quiet update --init)
	fi
	success
}

function list {
	if [ `(find $repos -type d; find $repos -type l)  | wc -l` -lt 2 ]; then
		err "No castles exist for homeshick in: $repos"
	fi
	for repo in `echo "$repos/*"`; do
		local remote_url=$(cd $repo; git config remote.origin.url)
		local reponame=`basename $repo`
		status $bldblu $reponame $remote_url
	done
	check_updates
}

function updates {
	if [ `(find $repos -type d; find $repos -type l)  | wc -l` -lt 2 ]; then
		err "No castles exist for homeshick in: $repos"
	fi
	for repo in `echo "$repos/*"`; do
		local reponame=`basename $repo`
		pending 'checking' $reponame
		if [ -z "$B_PRETEND" ]; then
			local reponame=$(get_github_reponame $reponame)
			local ref=$(cd $repo; git symbolic-ref HEAD 2>/dev/null)
			if [ -n "$reponame" ]; then
				local remote_head=$(get_repo_head $reponame $ref)
				local local_head=$(cd $repo; git rev-parse HEAD)
				if [ "$remote_head" == "$local_head" ]; then
					success 'up to date'
				else
					if [ "$remote_head" ]; then
						fail 'outdated'
					else
						ignore 'private'
					fi
				fi
			else
				ignore 'not github'
			fi
		else
			success 'checked'
		fi
	done
}

function check_ {
	local repo="$repos/$1"
	castle_exists 'examine' $1
}

function get_repo_head {
	local repo=$1
	local ref=$2
	curl -sL https://api.github.com/repos/$repo/git/$ref | grep -Eo '[a-f0-9]{40}' | head -n 1
}

function get_github_reponame {
	local repo="$repos/$1"
	local remote_url=$(cd $repo; git config remote.origin.url)
	
	if [[ $remote_url =~ github.com ]]; then
		printf -- $remote_url | sed -E 's#.*github\.com.([^:/]+)/([^/.]+)(\.git)?$#\1/\2#'
	fi
}
