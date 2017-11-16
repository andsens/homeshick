#!/usr/bin/env bats

load ../helper

@test 'pull skips castles with no upstream remote' {
	castle 'rc-files'
	castle 'dotfiles'
	# The dotfiles FETCH_HEAD should not exist after cloning
	[ ! -e "$HOMESICK/repos/dotfiles/.git/FETCH_HEAD" ]
	(cd "$HOMESICK/repos/rc-files" && git remote rm origin)
	run "$HOMESHICK_FN" pull rc-files dotfiles
	[ $status -eq 0 ] # EX_SUCCESS
	# dotfiles FETCH_HEAD should exist if the castle was pulled
	[ -e "$HOMESICK/repos/dotfiles/.git/FETCH_HEAD" ]
}
