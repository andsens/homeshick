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
