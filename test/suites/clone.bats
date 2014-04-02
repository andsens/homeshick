#!/usr/bin/env bats

load ../helper

@test 'clone a repo' {
	fixture 'rc-files'
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/rc-files
}

@test 'clone a repo with spaces in name' {
	fixture 'repo with spaces in name'
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/repo\ with\ spaces\ in\ name
	[ -d "$HOMESICK/repos/repo with spaces in name" ]
}

@test 'prompt for symlinking after clone' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	fixture 'rc-files'
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN clone $REPO_FIXTURES/rc-files
			expect -ex "${esc}1;36m        clone${esc}0m $REPO_FIXTURES/rc-files\r${esc}1;32m        clone${esc}0m $REPO_FIXTURES/rc-files\r
${esc}1;37m      updates${esc}0m The castle rc-files has new files.\r
${esc}1;36m     symlink?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
			send "y\n"
			expect EOF
EOF
	[ -f "$HOME/.bashrc" ]
}

@test 'clone repo with dot in its name' {
	fixture '135.abc'
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/135.abc
	[ -e "$HOMESICK/repos/135.abc" ]
}

@test 'recursive clone with git version >= 1.6.5' {
	fixture 'nested-submodules'
	GIT_VERSION=$(git --version | grep 'git version' | cut -d ' ' -f 3)
	[[ ! $GIT_VERSION =~ ([0-9]+)(\.[0-9]+){0,3} ]] && skip 'could not detect git version'
	run version_compare $GIT_VERSION 1.6.5
	[[ $? == 2 ]] && skip 'git version too low'

	$HOMESHICK_FN --batch clone $REPO_FIXTURES/nested-submodules
	[ -e "$HOMESICK/repos/nested-submodules/level1/level2" ]
}

@test 'recursive clone with git version < 1.6.5' {
	fixture 'nested-submodules'
	mock_git_version 1.6.4

	$HOMESHICK_FN --batch clone $REPO_FIXTURES/nested-submodules
	[ -e "$HOMESICK/repos/nested-submodules/level1" ]
	[ ! -e "$HOMESICK/repos/nested-submodules/level1/level2/info" ]
}
