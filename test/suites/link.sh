#!/bin/bash

function oneTimeSetUp() {
	source $HOMESHICK_FN_SRC
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/module-files > /dev/null
}

function oneTimeTearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	rm -rf "$HOMESICK/repos/dotfiles"
	rm -rf "$HOMESICK/repos/module-files"
}

function tearDown() {
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

## This is the linking table we are trying to verify:
## "not directory" can be a regular file or a symlink to either a file or a directory
##        $HOME\repo    | not directory | directory ##
## ---------------------|---------------|---------- ##
## nonexistent          | link          | mkdir     ##
## symlink to repofile  | identical     | rm!&mkdir ##
## file                 | rm?&link      | rm?&mkdir ##
## directory            | rm?&link      | identical ##
## directory (symlink)  | rm?&link      | identical ##


## First row: nonexistent
## First column: not directory
function testFileToNonexistent() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
}

function testFileSymlinkToNonexistent() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-file $HOME/symlinked-file
}

function testDirSymlinkToNonexistent() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
}

function testDeadSymlinkToNonexistent() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/dead-symlink $HOME/dead-symlink
}

## Second column: directory
function testDirToNonexistent() {
	$HOMESHICK_FN --batch link dotfiles > /dev/null
	assertFalse "\`link' symlinked the .ssh directory" "[ -L $HOME/.ssh ]"
	assertTrue "\`link' did not create the .ssh directory" "[ -d $HOME/.ssh ]"
}


## Second row: symlink to repofile
## First column: not directory
function testFileToReposymlink() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/.bashrc)
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/.bashrc)
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
	assertSame "\`link' re-linked the .bashrc file" $inode_before $inode_after
}

function testFileSymlinkToReposymlink() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/symlinked-file)
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/symlinked-file)
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-file $HOME/symlinked-file
	assertSame "\`link' re-linked symlinked-file" $inode_before $inode_after
}

function testDirSymlinkToReposymlink() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/symlinked-directory)
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/symlinked-directory)
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
	assertSame "\`link' re-linked symlinked-directory" $inode_before $inode_after
}

function testDeadSymlinkToReposymlink() {
	$HOMESHICK_FN --batch link rc-files > /dev/null
	local inode_before=$(get_inode_no $HOME/dead-symlink)
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	local inode_after=$(get_inode_no $HOME/dead-symlink)
	assertSymlink $HOMESICK/repos/rc-files/home/dead-symlink $HOME/dead-symlink
	assertSame "\`link' re-linked dead-symlink" $inode_before $inode_after
}

## Second column: directory
function testLegacySymlinks() {
	# Recreate the legacy scenario
	ln -s $HOMESICK/repos/dotfiles/home/.ssh $HOME/.ssh
	$HOMESHICK_FN --batch --force link dotfiles > /dev/null
	# Without legacy handling if we were to run `file $HOME/.ssh/known_hosts` we would get
	# .ssh/known_hosts: symbolic link in a loop
	# The `test -e` is sufficient though
	assertTrue "known_hosts file is a symbolic loop or does not exist" "[ -e $HOME/.ssh/known_hosts ]"
}


## Third row: file
## First column: not directory
function testFileToFile() {
	touch $HOME/.bashrc
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
}

function testFileSymlinkToFile() {
	touch $HOME/symlinked-file
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-file $HOME/symlinked-file
}

function testDirSymlinkToFile() {
	mkdir $HOME/symlinked-directory
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
}

function testDeadSymlinkToFile() {
	touch $HOME/dead-symlink
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/dead-symlink $HOME/dead-symlink
}

## Second column: directory
function testDirToFile() {
	touch $HOME/.ssh
	$HOMESHICK_FN --batch --force link dotfiles > /dev/null
	assertTrue "[ -d $HOME/.ssh ]"
	assertFalse "[ -L $HOME/.ssh ]"
}


## Fourth row: directory
## First column: not directory
function testFileToDir() {
	mkdir $HOME/.bashrc
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
}

function testFileSymlinkToDir() {
	mkdir $HOME/symlinked-file
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-file $HOME/symlinked-file
}

function testDirSymlinkToDir() {
	mkdir $HOME/symlinked-directory
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
}

function testDeadSymlinkToDir() {
	mkdir $HOME/dead-symlink
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/dead-symlink $HOME/dead-symlink
}

## Second column: directory
function testDirToDir() {
	mkdir $HOME/.ssh
	local inode_before=$(get_inode_no $HOME/.ssh)
	$HOMESHICK_FN --batch --force link dotfiles > /dev/null
	local inode_after=$(get_inode_no $HOME/.ssh)
	assertSame "\`link' recreated .ssh" $inode_before $inode_after
	assertTrue "[ -d $HOME/.ssh ]"
	assertFalse "[ -L $HOME/.ssh ]"
}


## Fourth row: directory
## First column: not directory
function testFileToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/.bashrc
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
	rm -rf $NOTHOME/symlink-target-dir
}

function testFileSymlinkToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/symlinked-file
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-file $HOME/symlinked-file
	rm -rf $NOTHOME/symlink-target-dir
}

function testDirSymlinkToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/symlinked-directory
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/symlinked-directory $HOME/symlinked-directory
	rm -rf $NOTHOME/symlink-target-dir
}

function testDeadSymlinkToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/dead-symlink
	$HOMESHICK_FN --batch --force link rc-files > /dev/null
	assertSymlink $HOMESICK/repos/rc-files/home/dead-symlink $HOME/dead-symlink
	rm -rf $NOTHOME/symlink-target-dir
}

## Second column: directory
function testDirToDirSymlink() {
	mkdir $NOTHOME/symlink-target-dir
	ln -s $NOTHOME/symlink-target-dir $HOME/.ssh
	local inode_before=$(get_inode_no $HOME/.ssh)
	$HOMESHICK_FN --batch --force link dotfiles > /dev/null
	local inode_after=$(get_inode_no $HOME/.ssh)
	assertSymlink $NOTHOME/symlink-target-dir $HOME/.ssh
	assertSame "\`link' recreated .ssh" $inode_before $inode_after
	assertTrue "[ -d $HOME/.ssh ]"
	assertTrue "[ -L $HOME/.ssh ]"
	rm -rf $NOTHOME/symlink-target-dir
}


function testOverwritePrompt() {
	touch $HOME/.bashrc
	$HOMESHICK_FN --batch link rc-files > /dev/null
	assertTrue "\`link' overwrote .bashrc" "[ -f $HOME/.bashrc -a ! -L $HOME/.bashrc ]"
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
	target=$(readlink $path)
	assertTrue "The file $path does not exist." "[ -e $path -o -L $path ]"
	[ -e $path -o -L $path ] || startSkipping
	assertTrue "The file $path is not a symlink." "[ -L $path ]"
	[ -L $path ] || startSkipping
	assertSame "The file $path does not point at the expected target." "$expected" "$target"
}

source $SHUNIT2
