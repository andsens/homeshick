#!/bin/bash

function oneTimeSetUp() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/deep-files > /dev/null
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
}

function testDeepLinking() {
	assertTrue "The .config/foo.conf file did not exist before symlinking" "[ -f $HOME/.config/foo.conf ]"
	#.config/foo.conf should be overwritten by a directory of the same name
	assertTrue "The .config/bar.dir/ directory did not exist before symlinking" "[ -d $HOME/.config/bar.dir ]"
	#.config/bar.dir should be overwritten by a file of the same name
	$HOMESHICK_BIN --batch --force link deep-files > /dev/null
	assertTrue "'link' did not symlink the .config/foo.conf directory" "[ -d $HOME/.config/foo.conf ]"
	assertTrue "'link' did not symlink the .config/bar.dir directory" "[ -f $HOME/.config/bar.dir ]"
}

function oneTimeTearDown() {
	rm -rf "$HOMESICK/repos/deep-files"
	find "$HOME" -mindepth 1 -not -name '.homesick' -not -name '.homeshick' -not -name '.gitconfig' -delete 
}

source $SHUNIT2
