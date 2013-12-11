#!/bin/bash

function oneTimeSetUp() {
	source $HOMESHICK_FN_SRC
}

function setUp() {
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$HOMESHICK_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
}

function tearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	rm -rf "$HOMESICK/repos/repo with spaces in name"
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

function testAbsolute() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function testPathWithSpaces() {
	cat > $HOME/.path\ with\ spaces <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.path\ with\ spaces > /dev/null
	assertEquals "\`track' did not exit with status 0" 0 $?
	assertTrue "\`track' did not move the \`.path with spaces' file" "[ -f $HOMESICK/repos/rc-files/home/.path\ with\ spaces ]"
	assertTrue "\`track' did not symlink the \`.path with spaces' file" "[ -L $HOME/.path\ with\ spaces ]"
}

function testPathWithSpaces2() {
	mkdir -p $HOME/deep\ folder/structure/with\ spaces
	local file=$HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	cat > "$file" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces > /dev/null
	assertEquals "\`track' did not exit with status 0" 0 $?
	assertTrue "\`track' did not move the \`.file with spaces' file" "[ -f $HOMESICK/repos/rc-files/home/deep\ folder/structure/with\ spaces/.file\ with\ spaces ]"
	assertTrue "\`track' did not symlink the \`.file with spaces' file" "[ -L \"$file\" ]"
}

function testTwoPathsWithSpaces() {
	mkdir -p $HOME/deep\ folder/structure/with\ spaces
	local file1=$HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	local file2=$HOME/.path\ with\ spaces
	cat > "$file1" <<EOF
homeshick --batch refresh
EOF
	cat > "$file2" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.path\ with\ spaces $HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces > /dev/null
	assertEquals "\`track' did not exit with status 0" 0 $?
	assertTrue "\`track' did not move the \`.file with spaces' file" "[ -f $HOMESICK/repos/rc-files/home/deep\ folder/structure/with\ spaces/.file\ with\ spaces ]"
	assertTrue "\`track' did not symlink the \`.file with spaces' file" "[ -L \"$file1\" ]"
	assertTrue "\`track' did not move the \`.path with spaces' file" "[ -f $HOMESICK/repos/rc-files/home/.path\ with\ spaces ]"
	assertTrue "\`track' did not symlink the \`.path with spaces' file" "[ -L \"$file2\" ]"
}

function testRelative() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	(cd $HOME; $HOMESHICK_FN track rc-files .zshrc) > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function testRepoWithSpaces() {
	cat > $HOME/.vimrc <<EOF
My empty vim config
EOF
	(cd $HOME; $HOMESHICK_FN track repo\ with\ spaces\ in\ name .vimrc) > /dev/null
	local file="$HOMESICK/repos/repo with spaces in name/home/.vimrc"
	assertTrue "\`track' did not move the .vimrc file" "[ -f \"$file\" ]"
	assertTrue "\`track' did not symlink the .vimrc file" "[ -L $HOME/.vimrc ]"
}

function testNOutsideHomedir() {
	cat > $NOTHOME/some_other_file <<EOF
homeshick should refuse to track this file
EOF
	$HOMESHICK_FN track rc-files $NOTHOME/some_other_file &> /dev/null
	assertTrue "\`track' moved \`some_other_file'" "[ -e $NOTHOME/some_other_file ]"
	assertTrue "\`track' symlinked \`some_other_file'" "[ ! -L $NOTHOME/some_other_file ]"
	rm $NOTHOME/some_other_file
}

function testNOverwrite() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
	rm $HOME/.zshrc
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh 7
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc &> /dev/null
	local tracked_file_size=$(stat -c %s $HOMESICK/repos/rc-files/home/.zshrc 2>/dev/null || \
	                          stat -f %z $HOMESICK/repos/rc-files/home/.zshrc)
	assertSame "\`track' has overwritten the previously tracked .zshrc file" 26 $tracked_file_size
	assertTrue "\`track' has overwritten the new .zshrc file" "[ ! -L $HOME/.zshrc ]"
}

function testNDoubleTracking() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
	$HOMESHICK_FN track rc-files $HOME/.zshrc &> /dev/null
	assertTrue "\`track' has double tracked the .zshrc file" "[ ! -L $HOMESICK/repos/rc-files/home/.zshrc ]"
}

function testGitAdd() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc > /dev/null
	local git_status=$(cd $HOMESICK/repos/rc-files; git status --porcelain)
	assertEquals ".zshrc seems not to be staged" "A  home/.zshrc" "$git_status"
}

source $SHUNIT2
