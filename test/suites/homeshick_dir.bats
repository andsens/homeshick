#!/usr/bin/env bats

load ../helper

@test 'bash with homeshick_dir override' {
	castle 'dotfiles'
	local result
	result=$( HOMESHICK_DIR=$_TMPDIR/nowhere "$HOMESHICK_FN" 2>&1 >/dev/null ) || true
	[[ "$result" =~ "/nowhere/" ]]
}

@test 'fish with homeshick_dir override' {
	[ "$(type -t fish)" = "file" ] || skip "fish not installed"
	cmd="source "$HOMESHICK_FN_SRC_FISH"; set HOMESHICK_DIR \"$_TMPDIR/nowhere\"; $HOMESHICK_FN"
	local result=$( fish <<< "$cmd" 2>&1 >/dev/null )
	[[ "$result" =~ "/nowhere/" ]]
}

@test 'csh with homeshick_dir override' {
	[ "$(type -t csh)" = "file" ] || skip "csh not installed"
	cmd="set HOMESHICK_DIR=/nowhere; source \"${HOMESHICK_FN_SRC_CSH}\""
	local result=$( csh <<< "$cmd" 2>&1 >/dev/null )
	[[ "$result" =~ "/nowhere/" ]]
}

