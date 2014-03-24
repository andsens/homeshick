#!/usr/bin/env bash

function export_env_vars {
	if [[ -n $BATS_TEST_DIRNAME ]]; then
		export TESTDIR=$(cd "${BATS_TEST_DIRNAME}/.."; printf "$(pwd)")
	else
		export TESTDIR=$(cd "${SCRIPTDIR}"; printf "$(pwd)")
	fi
	export _TMPDIR=$(mktemp -d)
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

function remove_path {
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
	ln -s $(cd "${TESTDIR}/../utils"; printf "$(pwd)") "${hs_repo}/utils"
	ln -s $(cd "${TESTDIR}/../completions"; printf "$(pwd)") "${hs_repo}/completions"
}

function rm_structure {
	# Make sure _TMPDIR wasn't unset
	[[ -n $_TMPDIR ]] && rm -rf $_TMPDIR
}

function setup_env {
	export_env_vars
	remove_path
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
	[[ -e "${REPO_FIXTURES}/$name" ]] || source "${TESTDIR}/fixtures/${name}.bash"
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
