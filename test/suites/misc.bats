#!/usr/bin/env bats

load ../helper

@test 'invoke non existing command' {
	run $HOMESHICK_FN commandthatdoesnexist
	[ $status -eq 64 ] # EX_USAGE
}

@test 'umask should not change after linking a file' {
	orig_umask=$(umask)

	castle 'rc-files'
	file="$HOMESICK/repos/rc-files/home/filename"
	touch $file
	chmod 0600 $file
	$HOMESHICK_FN --batch link rc-files

	[ $orig_umask = $(umask) ]
}
