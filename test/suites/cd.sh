#!/bin/bash

function setUp() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/my_module > /dev/null
}

function tearDown() {
	rm -rf "$HOMESICK/repos/dotfiles"
	rm -rf "$HOMESICK/repos/my_module"
}

function testPwd() {
	local dotfiles_home=$HOMESICK/repos/dotfiles/home
	local result=$($HOMESHICK_SRC cd dotfiles && pwd)
	assertSame "\`cd' did not change to the correct directory" "$dotfiles_home" "$result"
}

function testPwdNoHome() {
	local my_module_dir=$HOMESICK/repos/my_module
	local result=$($HOMESHICK_SRC cd my_module && pwd)
	assertSame "\`cd' did not change to the correct directory" "$my_module_dir" "$result"
}

function testNNonExistent() {
	local current_dir=$(pwd)
	local result=$($HOMESHICK_SRC cd non_existent 2>/dev/null; pwd)
	assertSame "\`cd' changed directory" "$current_dir" "$result"
}

function testNExitCode() {
	local result
	$HOMESHICK_SRC cd non_existent 2>/dev/null
	result=$?
	assertEquals "\`cd' did not exit with code 1" 1 $result
}

source $SHUNIT2
