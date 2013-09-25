#!/usr/bin/env bash -e


function testList() {
	$HOMESHICK_SRC --batch clone $REPO_FIXTURES/rc-files > /dev/null
	$HOMESHICK_SRC --batch clone $REPO_FIXTURES/dotfiles > /dev/null
	$HOMESHICK_SRC --batch clone $REPO_FIXTURES/module-files > /dev/null
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f - > /dev/null
		spawn $HOMESHICK_BIN list
		expect -ex "${esc}1;37m     dotfiles${esc}0m $REPO_FIXTURES/dotfiles\r
${esc}1;37m module-files${esc}0m $REPO_FIXTURES/module-files\r
${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
	assertEquals "Failed verifying the list command output." 0 $?

	rm -rf "$HOMESICK/repos/rc-files"
	rm -rf "$HOMESICK/repos/dotfiles"
	rm -rf "$HOMESICK/repos/module-files"
}

function testListAlteredUpstreamRemoteName() {
	$HOMESHICK_SRC --batch clone $REPO_FIXTURES/rc-files > /dev/null
	(cd $HOMESICK/repos/rc-files; git remote rename origin nigiro)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f - > /dev/null
		spawn $HOMESHICK_BIN list
		expect -ex "${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
	assertEquals "Failed verifying the list command output." 0 $?

	rm -rf "$HOMESICK/repos/rc-files"
}

function testSlashInBranch() {
	$HOMESHICK_SRC --batch clone $REPO_FIXTURES/rc-files > /dev/null
	(cd $HOMESICK/repos/rc-files; git checkout branch/with/slash >/dev/null 2>&1)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f - > /dev/null
		spawn $HOMESHICK_BIN list
		expect -ex "${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
	assertEquals "Failed verifying the list command output." 0 $?

	rm -rf "$HOMESICK/repos/rc-files"
}

source $SHUNIT2
