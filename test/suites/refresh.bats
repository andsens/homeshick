#!/usr/bin/env bats

load ../helper

@test 'refresh a freshly cloned castle' {
	castle 'rc-files'
	run $HOMESHICK_FN refresh -b rc-files
	[ $status -eq 87 ] # EX_TH_EXCEEDED

	$EXPECT_INSTALLED || skip 'expect not installed'
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN refresh rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     outdated${esc}0m rc-files\r
${esc}1;37m      refresh${esc}0m The castle rc-files is outdated.\r
${esc}1;36m        pull?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
			send "y\n"
			expect EOF
EOF
}

@test 'refresh a castle that was just pulled' {
	castle 'rc-files'
	$HOMESHICK_FN pull rc-files
	$HOMESHICK_FN -b refresh 7 rc-files
}

@test 'refresh a castle that was pulled 8 days ago' {
	castle 'rc-files'
	$HOMESHICK_FN pull rc-files # creates the FETCH_HEAD file

	local fetch_head="$HOMESICK/repos/rc-files/.git/FETCH_HEAD"
	system=`uname -a`
	if [[ "$system" =~ "Linux" ]]; then
		local timestamp=$(date -d@$(($(date +%s)-6*86400)) '+%Y%m%d%H%M.%S')
	else
		# assume BSD system
		local timestamp=$(date -r $(($(date +%s)-6*86400)) '+%Y%m%d%H%M.%S')
	fi
	touch -t $timestamp $fetch_head
	run $HOMESHICK_FN refresh -b rc-files
	[ $status -eq 87 ] # EX_TH_EXCEEDED

	$EXPECT_INSTALLED || skip 'expect not installed'
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN refresh rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     outdated${esc}0m rc-files\r
${esc}1;37m      refresh${esc}0m The castle rc-files is outdated.\r
${esc}1;36m        pull?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
			send "y\n"
			expect EOF
EOF
}


@test 'refresh a castle and check that it is up to date' {
	castle 'rc-files'

	local current_head=$(cd "$HOMESICK/repos/rc-files"; git rev-parse HEAD)
	(cd "$HOMESICK/repos/rc-files"; git reset --hard HEAD^1)

	$EXPECT_INSTALLED || skip 'expect not installed'
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN refresh rc-files
			expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     outdated${esc}0m rc-files\r
${esc}1;37m      refresh${esc}0m The castle rc-files is outdated.\r
${esc}1;36m        pull?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
			send "y\n"
			expect EOF
EOF
	local pulled_head=$(cd "$HOMESICK/repos/rc-files"; git rev-parse HEAD)
	[ "$current_head" = "$pulled_head" ]
}
