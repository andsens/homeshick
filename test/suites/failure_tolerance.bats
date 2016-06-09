#!/usr/bin/env bats

load ../helper

@test 'check non-existent and existent castle' {
	castle 'rc-files'
	run $HOMESHICK_FN check non-existent rc-files
	[ $status -eq 1 ] # EX_ERR
}

@test 'clone non-existent and existent castle' {
	fixture 'rc-files'
	run $HOMESHICK_FN --batch clone $REPO_FIXTURES/non-existent $REPO_FIXTURES/rc-files
	[ $status -eq 70 ] # EX_SOFTWARE
	[ ! -d "$HOMESICK/repos/rc-files" ] # Should not exist, clone must fail early
}

@test 'generate castles with and without naming conflict' {
	castle 'rc-files'
	run $HOMESHICK_FN generate rc-files nonexistent
	[ $status -eq 1 ] # EX_ERR
	[ ! -d "$HOMESICK/repos/nonexistent" ] # Should not exist, generate must fail early
}

@test 'link non-existent and existent castle' {
	castle 'rc-files'
	run $HOMESHICK_FN link --batch rc-files nonexistent
	[ $status -eq 1 ] # EX_ERR
}

@test 'pull non-existent and existent castle' {
	castle 'rc-files'
	local current_head=$(cd "$HOMESICK/repos/rc-files"; git rev-parse HEAD)
	(cd "$HOMESICK/repos/rc-files"; git reset --hard HEAD^1)
	run $HOMESHICK_FN pull --batch non-existent rc-files
	[ $status -eq 1 ] # EX_ERR
	local pulled_head=$(cd "$HOMESICK/repos/rc-files"; git rev-parse HEAD)
	[ "$current_head" = "$pulled_head" ]
}

@test 'refresh non-existent and existent castle' {
	castle 'rc-files'
	$HOMESHICK_FN pull rc-files
	run $HOMESHICK_FN refresh --batch 7 non-existent rc-files
	[ $status -eq 1 ] # EX_ERR
}

@test 'track non-existent and existent file in castle' {
	castle 'rc-files'
	touch $HOME/.newfiletotrack
	run $HOMESHICK_FN track rc-files $HOME/.newfiletotrack $HOME/.nonexistent
	[ $status -eq 1 ] # EX_ERR
	[ -f "$HOMESICK/repos/rc-files/home/.newfiletotrack" ]
}

@test 'track existent and non-existent file in castle' {
	castle 'rc-files'
	touch $HOME/.newfiletotrack
	run $HOMESHICK_FN track rc-files non-existent .newfiletotrack
	[ $status -eq 1 ] # EX_ERR
	[ ! -f "$HOMESICK/repos/rc-files/home/.newfiletotrack" ]
}
