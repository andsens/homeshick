#!/usr/bin/env bash -e

function tearDown() {
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

function testCloning() {
	$HOMESHICK_SRC --batch clone $REPO_FIXTURES/rc-files > /dev/null
	assertSame "\`clone' did not exit with status 0" 0 $?
	rm -rf "$HOMESICK/repos/rc-files"
}

function testSymlinkPrompt() {
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	cat <<EOF | expect -f - > /dev/null
		spawn $HOMESHICK_BIN clone $REPO_FIXTURES/rc-files
		expect -ex "${esc}1;36m        clone${esc}0m $REPO_FIXTURES/rc-files\r${esc}1;32m        clone${esc}0m $REPO_FIXTURES/rc-files\r
${esc}1;37m      updates${esc}0m The castle rc-files has new files.\r
${esc}1;36m     symlink?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
		send "y\n"
		expect EOF
EOF
	assertEquals "Failed verifying the clone command output." 0 $?
	assertTrue "bashrc not symlinked after prompt" "[ -f $HOME/.bashrc ]"
	rm -f "$HOME/.bashrc"
	rm -rf "$HOMESICK/repos/rc-files"
}

source $SHUNIT2
