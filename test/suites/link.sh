#!/bin/bash

function oneTimeSetUp() {
	source $HOMESHICK_FN_SRC
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/module-files > /dev/null
	$HOMESHICK_FN --batch clone "$REPO_FIXTURES/repo with spaces in name" > /dev/null
}

function oneTimeTearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	rm -rf "$HOMESICK/repos/dotfiles"
	rm -rf "$HOMESICK/repos/module-files"
	rm -rf "$HOMESICK/repos/repo with spaces in name"
}

function tearDown() {
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}


function testOverwritePrompt() {
	touch $HOME/.bashrc
	$HOMESHICK_FN --batch link rc-files > /dev/null
	assertTrue "\`link' overwrote .bashrc" "[ -f $HOME/.bashrc -a ! -L $HOME/.bashrc ]"
}

function testOverwriteAnswerYes() {
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	if $EXPECT_INSTALLED; then
		touch $HOME/.bashrc
		cat <<EOF | expect -f - > /dev/null
			spawn $HOMESHICK_BIN link rc-files
			expect -ex "${esc}1;37m     conflict${esc}0m .bashrc exists\r
${esc}1;36m   overwrite?${esc}0m ${open_bracket}yN${close_bracket}"
			send "y\n"
			expect EOF
EOF
	else
		startSkipping
	fi
	assertTrue "\`link' did not overwrite .bashrc" "[ -L $HOME/.bashrc ]"
}

function testOverwriteSkip() {
	touch $HOME/.bashrc
	$HOMESHICK_FN --skip link rc-files > /dev/null
	assertTrue "\`link' overwrote .bashrc" "[ -f $HOME/.bashrc -a ! -L $HOME/.bashrc ]"
}

function testReSymlinkDirectory() {
	$HOMESHICK_FN --batch link module-files > /dev/null
	local inode_before=$(get_inode_no $HOME/.my_module)
	$HOMESHICK_FN --batch link module-files > /dev/null
	local inode_after=$(get_inode_no $HOME/.my_module)
	assertSame "\`link' re-linked the .my_module directory symlink" $inode_before $inode_after
}



function testDeepLinking() {
	mkdir -p $HOME/.config/bar.dir
	cat > $HOME/.config/foo.conf <<EOF
#I am just a regular foo.conf file 
[foo]
A=True
EOF
	cat > $HOME/.config/bar.dir/bar.conf <<EOF
#I am just a regular bar.conf file 
[bar]
A=True
EOF
	
	assertTrue "The .config/foo.conf file did not exist before symlinking" "[ -f $HOME/.config/foo.conf ]"
	#.config/foo.conf should be overwritten by a directory of the same name
	assertTrue "The .config/bar.dir/ directory did not exist before symlinking" "[ -d $HOME/.config/bar.dir ]"
	#.config/bar.dir should be overwritten by a file of the same name
	$HOMESHICK_FN --batch --force link dotfiles > /dev/null
	assertTrue "'link' did not symlink the .config/foo.conf directory" "[ -d $HOME/.config/foo.conf ]"
	assertTrue "'link' did not symlink the .config/bar.dir directory" "[ -f $HOME/.config/bar.dir ]"
}

function testSymlinkDirectory() {
	$HOMESHICK_FN --batch link module-files > /dev/null
	assertTrue "'link' did not symlink the .my_module symlink" "[ -L $HOME/.my_module ]"
}

function testGitDirIgnore() {
	$HOMESHICK_FN --batch link dotfiles > /dev/null
	assertFalse "'link' did not ignore the .git submodule file" "[ -e $HOME/.vim/.git ]"
}

function testCastleWithSpacesInName() {
	$HOMESHICK_FN --batch link repo\ with\ spaces\ in\ name > /dev/null
	assertSame "\`link' did not exit with status 0" 0 $?
	assertTrue "'link' did not symlink the .repowithspacesfile file" "[ -f $HOME/.repowithspacesfile ]"
}

function testMultipleCastles() {
	$HOMESHICK_FN --batch link rc-files dotfiles repo\ with\ spaces\ in\ name > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
	assertSymlink $HOMESICK/repos/dotfiles/home/.ssh/known_hosts $HOME/.ssh/known_hosts
	assertSymlink "$HOMESICK/repos/repo with spaces in name/home/.repowithspacesfile" $HOME/.repowithspacesfile
}

function testAllCastles() {
	$HOMESHICK_FN --batch link > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
	assertSymlink $HOMESICK/repos/dotfiles/home/.ssh/known_hosts $HOME/.ssh/known_hosts
	assertSymlink "$HOMESICK/repos/repo with spaces in name/home/.repowithspacesfile" $HOME/.repowithspacesfile
}

function get_inode_no() {
	stat -c %i $1 2>/dev/null || stat -f %i $1
}

function assertSymlink() {
	message=''
	if [[ $# == 3 ]]; then
		message=$1
		shift
	fi
	expected=$1
	path=$2
	target=$(readlink "$path")
	assertTrue "The file $path does not exist." "[ -e $path -o -L $path ]"
	[ -e $path -o -L $path ] || startSkipping
	assertTrue "The file $path is not a symlink." "[ -L $path ]"
	[ -L $path ] || startSkipping
	assertSame "The file $path does not point at the expected target." "$expected" "$target"
}

source $SHUNIT2
