#!/usr/bin/env bats

load ../helper

@test 'invoke non existing command' {
	run "$HOMESHICK_FN" commandthatdoesnexist
	[ $status -eq 64 ] # EX_USAGE
}

@test 'verbose mode should print identical messages when linking' {
	castle 'symlinks'
	$HOMESHICK_FN link symlinks
	$HOMESHICK_FN -v link symlinks | grep identical
}

@test 'normal verbosity should not print identical messages when linking' {
	castle 'symlinks'
	$HOMESHICK_FN link symlinks
	[ ! $($HOMESHICK_FN link symlinks | grep identical) ]
}

@test 'link non-existent castle' {
	run "$HOMESHICK_FN" link nonexistent
	[ $status -eq 1 ] # EX_ERR
}

@test 'error should end with a single newline' {
	$HOMESHICK_FN --batch generate existing-repo
	output=$($HOMESHICK_FN --batch generate existing-repo 2>&1 | tr '\n' 'n')
	run grep -q 'nn$' <<<"$output"
	[ $status -eq 1 ]
}

@test 'fish function should not print errors when invoked without arguments' {
	[ "$(type -t fish)" = "file" ] || skip "fish not installed"
	cmd="source "$HOMESHICK_FN_SRC_FISH"; and $HOMESHICK_FN"
	local stderr
	stderr=$( fish <<< "$cmd" 2>&1 >/dev/null )
	[ -z "$stderr" ]
}
