#!/usr/bin/env bats

load ../helper

function add_new_file_to_castle {
	cd "$HOMESICK/repos/rc-files";
	touch homeshick_new_file_bats_test
}

function modify_file_in_castle {
	cd "$HOMESICK/repos/rc-files";
	echo modify >> $(find home -type f | head -1)
}

function delete_file_in_castle {
	cd "$HOMESICK/repos/rc-files";
	rm $(find home -type f | head -1)
}

function add_commit_to_castle {
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
}

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

@test 'check a castle that is behind upstream with a new file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(cd "$HOMESICK/repos/rc-files"; git reset --hard HEAD^; add_new_file_to_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is behind upstream with a modified file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(cd "$HOMESICK/repos/rc-files"; git reset --hard HEAD^1; modify_file_in_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is behind upstream with a deleted file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(cd "$HOMESICK/repos/rc-files"; git reset --hard HEAD^1; delete_file_in_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(add_commit_to_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream with a new file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(add_commit_to_castle; add_new_file_to_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream with a modified file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(add_commit_to_castle; modify_file_in_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream with a deleted file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(add_commit_to_castle; delete_file_in_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}


@test 'check a castle with a new file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(add_new_file_to_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     modified${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle with a modified file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(modify_file_in_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     modified${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle with a deleted file' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(delete_file_in_castle)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN check rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     modified${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}
