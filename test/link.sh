#!/bin/bash -e

function oneTimeSetUp() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/rc-files > /dev/null
}

function testLinking() {
	assertFalse "The .bashrc file existed before symlinking" "[ -e $HOME/.bashrc ]"
	$HOMESHICK_BIN --batch link rc-files > /dev/null
	assertTrue "\`link' did not symlink the .bashrc file" "[ -e $HOME/.bashrc ]"
}

function oneTimeTearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	find "$HOME" -depth 1 -not -name '.homesick' -not -name '.homeshick' -exec rm -rf {} \;
}

source $SHUNIT2
