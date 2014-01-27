#!/bin/bash

function oneTimeSetUp() {
	source $HOMESHICK_FN_SRC
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
        	$HOMESHICK_FN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
        	$HOMESHICK_FN --batch clone $REPO_FIXTURES/module-files > /dev/null
        	$HOMESHICK_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/install_update > /dev/null
}

function oneTimeTearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
        	rm -rf "$HOMESICK/repos/dotfiles"
        	rm -rf "$HOMESICK/repos/module-files"
        	rm -rf "$HOMESICK/repos/repo with spaces in name"
	rm -rf "$HOMESICK/repos/install_update"
}

function tearDown() {
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

function testInstall() {
	$HOMESHICK_FN --batch install install_update > /dev/null
	assertTrue "\`install' created update file" "[ -f $REPO_FIXTURES/install_update/update ]"
}

function testUpdate() {
	echo "cp update finished" >> $REPO_FIXTURES/install_update/update
	$HOMESHICK_FN --batch update install_update > /dev/null
	assertTrue "\`update' created finished file" "[ -f $REPO_FIXTURES/install_update/finished ]"
}

source $SHUNIT2
