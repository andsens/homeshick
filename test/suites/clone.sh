#!/usr/bin/env bash -e

function testCloning() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	assertSame "\`clone' did not exit with status 0" 0 $?
}

function testSymlinkPrompt() {
	cat <<EOF | expect -f - > /dev/null
		spawn $HOMESHICK_BIN clone $REPO_FIXTURES/rc-files
		expect "*clone*$REPO_FIXTURES/rc-files"
		expect "*updates*The castle rc-files has new files."
		expect "symlink?*\[yN\]"
		send "y\r"
		expect EOF
EOF
	assertTrue 'bashrc symlinked after prompt' "[ -f $HOME/.bashrc ]"
}

function tearDown() {
	rm -f "$HOME/.bashrc"
	rm -rf "$HOMESICK/repos/rc-files"
}

source $SHUNIT2
