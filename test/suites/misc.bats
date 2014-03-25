#!/usr/bin/env bats

load ../helper

@test 'invoke non existing command' {
	run $HOMESHICK_FN commandthatdoesnexist
	[ $status -eq 64 ] # EX_USAGE
}
