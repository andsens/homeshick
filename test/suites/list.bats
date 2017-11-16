#!/usr/bin/env bats

load ../helper

@test 'list all castles' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	castle 'dotfiles'
	castle 'module-files'
	castle 'repo with spaces in name'
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn "$HOMESHICK_BIN" list
			expect -ex "${esc}1;37m     dotfiles${esc}0m $REPO_FIXTURES/dotfiles\r
${esc}1;37m module-files${esc}0m $REPO_FIXTURES/module-files\r
${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r
${esc}1;37mrepo with spaces in name${esc}0m $REPO_FIXTURES/repo with spaces in name\r\n" {} default {exit 1}
EOF
}

@test 'list castle with spaces in castlename' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'repo with spaces in name'
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn "$HOMESHICK_BIN" list
			expect -ex "${esc}1;37mrepo with spaces in name${esc}0m $REPO_FIXTURES/repo with spaces in name\r\n" {} default {exit 1}
EOF
}

@test 'list castle with altered upstream remote name' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(cd "$HOMESICK/repos/rc-files" && git remote rename origin nigiro)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn "$HOMESHICK_BIN" list
			expect -ex "${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
}

@test 'list castle with slash in branchname' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	(cd "$HOMESICK/repos/rc-files" && git checkout branch/with/slash)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn "$HOMESHICK_BIN" list
			expect -ex "${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
}

@test 'list symlinks to castles' {
$EXPECT_INSTALLED || skip 'expect not installed'
	castle 'rc-files'
	(
		cd "$HOMESICK/repos/" && \
		mv rc-files "$_TMPDIR/rc-files" && \
		ln -s "$_TMPDIR/rc-files" ./rc-files
	)
	esc="\\u001b\\u005b"
	cat <<EOF | expect -f -
			spawn "$HOMESHICK_BIN" list
			expect -ex "${esc}1;37m     rc-files${esc}0m $REPO_FIXTURES/rc-files\r\n" {} default {exit 1}
EOF
}
