#!/bin/bash

function setUp() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/rc-files > /dev/null
}

function testSimpleTrackingAbsolute() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_BIN track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function testSimpleTrackingRelative() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	(cd $HOME; $HOMESHICK_BIN track rc-files .zshrc) > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function tearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

source $SHUNIT2
