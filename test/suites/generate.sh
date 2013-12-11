#!/usr/bin/env bash -e

function oneTimeSetUp() {
	source $HOMESHICK_FN_SRC
}

function testGenerateCastle() {
	$HOMESHICK_FN --batch generate my_repo > /dev/null
	local repo_path="$HOMESICK/repos/my_repo"
	assertSame "\`generate' did not exit with status 0" 0 $?
	assertTrue "\`generate' did not create the repo \`my_repo'" "[ -d \"$repo_path\" ]"
	rm -rf "$repo_path"
}

function testGenerateCastleWithSpaces() {
	$HOMESHICK_FN --batch generate my\ repo > /dev/null
	local repo_path="$HOMESICK/repos/my repo"
	assertSame "\`generate' did not exit with status 0" 0 $?
	assertTrue "\`generate' did not create the repo \`my repo'" "[ -d \"$repo_path\" ]"
	rm -rf "$repo_path"
}

source $SHUNIT2
