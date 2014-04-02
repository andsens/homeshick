#!/usr/bin/env bats

load ../helper

@test 'check an up to date castle' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;32m   up to date${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check an up to date castle with spaces in castle name' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'repo with spaces in name'
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check "repo with spaces in name"
			expect -ex "${esc}1;36m     checking${esc}0m repo with spaces in name\r${esc}1;32m   up to date${esc}0m repo with spaces in name\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is behind upstream' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(cd "$HOMESICK/repos/rc-files"; git reset --hard HEAD^1)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(
		cd "$HOMESICK/repos/rc-files"
		git config user.name "Homeshick user"
		git config user.email "homeshick@example.com"

		cat >> home/.bashrc <<EOF
#!/bin/bash
PS1='\[33[01;32m\]\u@\h\[33[00m\]:\[33[01;34m\]\w\'
homeshick --batch refresh
EOF
		git add home/.bashrc
		git commit -m 'Added homeshick refresh check to .bashrc'
	)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}
