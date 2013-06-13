#!/bin/bash

function oneTimeSetUp() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/module-files > /dev/null
}

function testLinking() {
	assertFalse "The .bashrc file existed before symlinking" "[ -e $HOME/.bashrc ]"
	$HOMESHICK_BIN --batch link rc-files > /dev/null
	assertTrue "\`link' did not symlink the .bashrc file" "[ -e $HOME/.bashrc ]"
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
	$HOMESHICK_BIN --batch --force link dotfiles > /dev/null
	assertTrue "'link' did not symlink the .config/foo.conf directory" "[ -d $HOME/.config/foo.conf ]"
	assertTrue "'link' did not symlink the .config/bar.dir directory" "[ -f $HOME/.config/bar.dir ]"
}

function testSymlinkDirectory() {
	assertFalse "The .my_module existed before symlinking" "[ -e $HOME/.my_module ]"
	$HOMESHICK_BIN --batch link module-files > /dev/null
	assertTrue "'link' did not symlink the .my_module symlink" "[ -L $HOME/.my_module ]"
}

function testLegacySymlinks() {
	assertTrue "known_hosts file does not exist" "[ -e $HOME/.ssh/known_hosts ]"
	rm -rf "$HOME/.ssh"
	# Recreate the legacy scenario
	ln -s $HOMESICK/repos/dotfiles/home/.ssh $HOME/.ssh
	$HOMESHICK_BIN --batch --force link dotfiles > /dev/null
	# Without legacy handling if we were to run `file $HOME/.ssh/known_hosts` we would get
	# .ssh/known_hosts: symbolic link in a loop
	# The `test -e` is sufficient though
	assertTrue "known_hosts file is a symbolic loop or does not exist" "[ -e $HOME/.ssh/known_hosts ]"
}

function oneTimeTearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	rm -rf "$HOMESICK/repos/dotfiles"
	rm -rf "$HOMESICK/repos/module-files"
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

source $SHUNIT2
