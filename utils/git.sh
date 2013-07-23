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
	[[ ! $1 ]] && help_err clone
	local git_repo=$1
	local repo_path="$repos/$(parse_url $git_repo)"
	if [[ $git_repo =~ ^([A-Za-z_-]+\/[A-Za-z_-]+)$ ]]; then
		git_repo="https://github.com/$git_repo.git"
	fi
	pending 'clone' $git_repo
	test -e $repo_path && err $EX_ERR "$repo_path already exists"

	local git_out
	if [[ $(version_compare $GIT_VERSION 1.6.5) -ge 0 ]]; then
		git_out=$(git clone --recursive $git_repo $repo_path 2>&1)
		[[ $? == 0 ]] || err $EX_SOFTWARE "Unable to clone $git_repo. Git says:" "$git_out"
		success
	else
		git_out=$(git clone $git_repo $repo_path 2>&1)
		[[ $? == 0 ]] || err $EX_SOFTWARE "Unable to clone $git_repo. Git says:" "$git_out"
		success

		pending 'submodules' $git_repo
		git_out=$(cd $repo_path; git submodule update --init 2>&1)
		[[ $? == 0 ]] || err $EX_SOFTWARE "Unable to clone submodules for $git_repo. Git says:" "$git_out"
		success
	fi
	return $EX_SUCCESS
}

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
	git_out=$(cd $repo; git init 2>&1)
	[[ $? == 0 ]] || err $EX_SOFTWARE "Unable to initialize repository $repo. Git says:" "$git_out"
	mkdir "$repo/home"
	success
	return $EX_SUCCESS
}

function pull {
	[[ ! $1 ]] && help_err pull
	local castle=$1
	local repo="$repos/$castle"
	pending 'pull' $castle
	castle_exists 'pull' $castle

	local git_out
	git_out=$(cd $repo; git pull 2>&1)
	[[ $? == 0 ]] || err $EX_SOFTWARE "Unable to pull $repo. Git says:" "$git_out"

	if [[ $(version_compare $GIT_VERSION 1.6.5) -ge 0 ]]; then
		git_out=$(cd $repo; git submodule update --recursive --init 2>&1)
		[[ $? == 0 ]] || err $EX_SOFTWARE "Unable update submodules for $repo. Git says:" "$git_out"
	else
		git_out=$(cd $repo; git submodule update --init 2>&1)
		[[ $? == 0 ]] || err $EX_SOFTWARE "Unable update submodules for $repo. Git says:" "$git_out"
	fi
	success
	return $EX_SUCCESS
}

function list {
	for reponame in $(list_castle_names); do
		local remote_url=$(cd $repos/$reponame; git config remote.origin.url)
		info $reponame $remote_url
	done
	return $EX_SUCCESS
}

function list_castle_names {
	for repo in $(find $repos -mindepth 2 -maxdepth 2 -name .git -type d | sed 's#/.git$##g' | sort); do
		local reponame=$(basename $repo)
		printf "$reponame\n"
	done
	return $EX_SUCCESS
}

function check {
	local exit_status=$EX_SUCCESS
	[[ ! $1 ]] && help_err check
	local castle=$1
	local repo="$repos/$castle"
	pending 'checking' $castle
	castle_exists 'check' $castle

	local ref=$(cd $repo; git symbolic-ref HEAD 2>/dev/null)
	local remote_url=$(cd $repo; git config remote.origin.url 2>/dev/null)
	local remote_head=$(git ls-remote -q --heads "$remote_url" "$ref" 2>/dev/null | cut -f 1)
	if [[ $remote_head ]]; then
		local local_head=$(cd $repo; git rev-parse HEAD)
		if [[ $remote_head == $local_head ]]; then
			success 'up to date'
			exit_status=$EX_SUCCESS
		else
			(cd $repo; git branch --contains "$remote_head" 2>/dev/null) > /dev/null
			if [[ $? == 0 ]]; then
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


function refresh {
	[[ ! $1 || ! $2 ]] && help_err last-update
	local threshhold=$1
	local castle=$2
	local fetch_head="$repos/$castle/.git/FETCH_HEAD"
	pending 'checking' $castle
	castle_exists 'check freshness' $castle

	if [[ -e "$fetch_head" ]]; then
		local last_mod=$(stat -c %Y "$fetch_head" 2> /dev/null || stat -f %m "$fetch_head")
		local time_now=$(date +%s)
		if [[ $((time_now-last_mod)) -gt $threshhold ]]; then
			fail "outdated"
			return $EX_TH_EXCEEDED
		else
			success "fresh"
			return $EX_SUCCESS
		fi
	else
		fail "outdated"
		return $EX_TH_EXCEEDED
	fi
}

function pull_outdated {
	local threshhold=$1; shift
	local outdated_castles=()
	while [[ $# -gt 0 ]]; do
		local castle=$1; shift
		local fetch_head="$repos/$castle/.git/FETCH_HEAD"
		# When in interactive mode:
		# No matter if we are going to pull the castles or not
		# we reset the outdated ones by touching FETCH_HEAD
		if [[ -e "$fetch_head" ]]; then
			local last_mod=$(stat -c %Y "$fetch_head" 2> /dev/null || stat -f %m "$fetch_head")
			local time_now=$(date +%s)
			if [[ $((time_now-last_mod)) -gt $threshhold ]]; then
				outdated_castles+=($castle)
				! $BATCH && touch "$fetch_head"
			fi
		else
			outdated_castles+=($castle)
			! $BATCH && touch "$fetch_head"
		fi
	done
	ask_pull ${outdated_castles[*]}
	return $EX_SUCCESS
}

function ask_pull {
	if [[ $# -gt 0 ]]; then
		if [[ $# == 1 ]]; then
			msg="The castle $1 is outdated."
		else
			OIFS=$IFS
			IFS=,
			msg="The castles $* are outdated."
			IFS=$OIFS
		fi
		prompt_no 'refresh' "$msg" 'pull?'
		if [[ $? = 0 ]]; then
			for castle in $*; do
				pull $castle
			done
		fi
	fi
	return $EX_SUCCESS
}

function symlink_cloned_files {
	local cloned_castles=()
	while [[ $# -gt 0 ]]; do
		local castle=$(parse_url $1)
		shift
		local repo="$repos/$castle"
		if [[ ! -d $repo/home ]]; then
			continue;
		fi
		local num_files=$(find $repo/home -mindepth 1 -maxdepth 1 | wc -l | tr -dc "0123456789")
		if [[ $num_files > 0 ]]; then
			cloned_castles+=($castle)
		fi
	done
	ask_symlink ${cloned_castles[*]}
	return $EX_SUCCESS
}

function symlink_new_files {
	local updated_castles=()
	while [[ $# -gt 0 ]]; do
		local castle=$1
		shift
		local repo="$repos/$castle"
		local git_out
		local now=$(date +%s)
		git_out=$(cd $repo; git diff --name-only --diff-filter=A HEAD@{$[$now-$T_START+1].seconds.ago} HEAD -- home 2>/dev/null | wc -l 2>&1)
		[[ $? == 0 ]] || continue # Ignore errors, this operation is not mission critical
		if [[ $git_out > 0 ]]; then
			updated_castles+=($castle)
		fi
	done
	ask_symlink ${updated_castles[*]}
	return $EX_SUCCESS
}

function ask_symlink {
	if [[ $# -gt 0 ]]; then
		if [[ $# == 1 ]]; then
			msg="The castle $1 has new files."
		else
			OIFS=$IFS
			IFS=,
			msg="The castles $* have new files."
			IFS=$OIFS
		fi
		prompt_no 'updates' "$msg" 'symlink?'
		if [[ $? = 0 ]]; then
			for castle in $*; do
				symlink $castle
			done
		fi
	fi
	return $EX_SUCCESS
}

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

