#!/bin/bash

function setUp() {
	$HOMESHICK_SRC --batch clone $REPO_FIXTURES/rc-files > /dev/null
}

function tearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

function testAbsolute() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_SRC track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function testRelative() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	(cd $HOME; $HOMESHICK_SRC track rc-files .zshrc) > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function testNOutsideHomedir() {
	cat > $NOTHOME/some_other_file <<EOF
homeshick should refuse to track this file
EOF
	$HOMESHICK_SRC track rc-files $NOTHOME/some_other_file &> /dev/null
	assertTrue "\`track' moved \`some_other_file'" "[ -e $NOTHOME/some_other_file ]"
	assertTrue "\`track' symlinked \`some_other_file'" "[ ! -L $NOTHOME/some_other_file ]"
	rm $NOTHOME/some_other_file
}

function testNOverwrite() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_SRC track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
	rm $HOME/.zshrc
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh 7
EOF
	$HOMESHICK_SRC track rc-files $HOME/.zshrc &> /dev/null
	local tracked_file_size=$(stat -c %s $HOMESICK/repos/rc-files/home/.zshrc 2>/dev/null || \
	                          stat -f %z $HOMESICK/repos/rc-files/home/.zshrc)
	assertSame "\`track' has overwritten the previously tracked .zshrc file" 26 $tracked_file_size
	assertTrue "\`track' has overwritten the new .zshrc file" "[ ! -L $HOME/.zshrc ]"
}

function testNDoubleTracking() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_SRC track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
	$HOMESHICK_SRC track rc-files $HOME/.zshrc &> /dev/null
	assertTrue "\`track' has double tracked the .zshrc file" "[ ! -L $HOMESICK/repos/rc-files/home/.zshrc ]"
}

function testGitAdd() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_SRC track rc-files $HOME/.zshrc > /dev/null
	local git_status=$(cd $HOMESICK/repos/rc-files; git status --porcelain)
	assertEquals ".zshrc seems not to be staged" "A  home/.zshrc" "$git_status"
}

source $SHUNIT2
