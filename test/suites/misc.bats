#!/usr/bin/env bats

load ../helper

@test 'invoke non existing command' {
	run $HOMESHICK_FN commandthatdoesnexist
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
