#!/usr/bin/env bats

load ../helper

@test 'generate a castle' {
	$HOMESHICK_FN --batch generate my_repo
	[ -d "$HOMESICK/repos/my_repo" ]
}

@test 'generate a castle with spaces in name' {
	$HOMESHICK_FN --batch generate my\ repo
	[ -d "$HOMESICK/repos/my repo" ]
}

@test 'generate a castle with spaces in name with fish' {
	[ "$(type -t fish)" = "file" ] || skip "fish not installed"
	cmd="source "$HOMESHICK_FN_SRC_FISH"; and $HOMESHICK_FN --batch generate my\ repo"
	fish <<< "$cmd" 2>&1
	[ -d "$HOMESICK/repos/my repo" ]
}