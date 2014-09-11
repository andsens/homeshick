#!/usr/bin/env bash

function export_env_vars {
	if [[ -n $BATS_TEST_DIRNAME ]]; then
		export TESTDIR=$(cd "${BATS_TEST_DIRNAME}/.."; printf "$(pwd)")
	else
		export TESTDIR=$(cd "${SCRIPTDIR}"; printf "$(pwd)")
	fi
	export _TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t homeshick)
	export REPO_FIXTURES="${_TMPDIR}/repos"
	export HOME="${_TMPDIR}/home"
	export NOTHOME="${_TMPDIR}/nothome"

	export HOMESICK="$HOME/.homesick"
	export HOMESHICK_FN="homeshick"
	export HOMESHICK_FN_SRC="$HOMESICK/repos/homeshick/homeshick.sh"
	export HOMESHICK_BIN="$HOMESICK/repos/homeshick/bin/homeshick"

	# Check if expect is installed
	run type expect >/dev/null 2>&1
	if [[ $status != 0 ]]; then
		export EXPECT_INSTALLED=false
	else
		export EXPECT_INSTALLED=true
	fi
}

function remove_coreutils_from_path {
	# Check if coreutils is in PATH
	system=$(uname -a)
	if [[ $system =~ "Darwin" && ! $system =~ "AppleTV" ]]; then
		run type brew >/dev/null 2>&1
		if [[ $status = 0 ]]; then
			coreutils_path=$(brew --prefix coreutils 2>/dev/null)/libexec/gnubin
			if [[ -d $coreutils_path && $PATH == *$coreutils_path* ]]; then
				if [[ -z $HOMESHICK_KEEP_PATH || $HOMESHICK_KEEP_PATH == false ]]; then
					export PATH=${PATH//$coreutils_path/''}
					export PATH=${PATH//'::'/':'} # Remove any left over colons
				fi
			fi
		fi
	fi
}

function mk_structure {
	mkdir "$REPO_FIXTURES" "$HOME" "$NOTHOME"
	local hs_repo=$HOMESICK/repos/homeshick
	mkdir -p $hs_repo
	ln -s $(cd "${TESTDIR}/.."; printf "$(pwd)")/homeshick.sh "${hs_repo}/homeshick.sh"
	ln -s $(cd "${TESTDIR}/../bin"; printf "$(pwd)") "${hs_repo}/bin"
	ln -s $(cd "${TESTDIR}/../lib"; printf "$(pwd)") "${hs_repo}/lib"
	ln -s $(cd "${TESTDIR}/../completions"; printf "$(pwd)") "${hs_repo}/completions"
}

function rm_structure {
	# Make sure _TMPDIR wasn't unset
	[[ -n $_TMPDIR ]] && rm -rf $_TMPDIR
}

function setup_env {
	remove_coreutils_from_path
	export_env_vars
	mk_structure
	source $HOMESHICK_FN_SRC
}

function setup {
	setup_env
}

function teardown {
	rm_structure
}

function fixture {
	local name=$1
	[[ -e "${REPO_FIXTURES}/$name" ]] || source "${TESTDIR}/fixtures/${name}.sh"
}

function castle {
	local fixture_name=$1
	fixture "$fixture_name"
	$HOMESHICK_FN --batch clone "${REPO_FIXTURES}/${fixture_name}" > /dev/null
}

function is_symlink {
	expected=$1
	path=$2
	target=$(readlink "$path")
	[ "$expected" = "$target" ]
}

function get_inode_no {
	stat -c %i $1 2>/dev/null || stat -f %i $1
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

function get_git_version {
	GIT_VERSION=$(git --version | grep 'git version' | cut -d ' ' -f 3)
	[[ ! $GIT_VERSION =~ ([0-9]+)(\.[0-9]+){0,3} ]] && skip 'could not detect git version'
	printf $GIT_VERSION
}

function mock_git_version {
	# To mock a git version we simply create a function wrapper for it
	# and forward all calls to git except `git --version`
	local real_git=$(which git)
	eval "
		function git {
			if [[ \$1 == '--version' ]]; then
					echo "git version $1"
					return 0
				else
					local res
					# Some variable expansions used by git internally may break,
					# if we just forward the arguments with '\$@',
					# so we unset this function until the execution is completed.
					unset git
					$real_git "\$@"
					res=\$?
					mock_git_version $1
					return \$res
			fi
		}
	"
	# The function needs to be exported for it to work in child processes
	export -f git
}

function commit_repo_state {
	local repo=$1
	(
		cd $repo
		git config user.name "Homeshick user"
		git config user.email "homeshick@example.com"
		git add -A
		git commit -m "Commiting Repo State from test helper.bash."
	)
}
