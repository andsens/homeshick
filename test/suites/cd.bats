#!/usr/bin/env bats

load ../helper

@test 'cd to dotfiles castle' {
	castle 'dotfiles'
	local dotfiles_dir=$HOMESICK/repos/dotfiles
	local result=$($HOMESHICK_FN cd dotfiles && pwd)
	[ "$dotfiles_dir" = "$result" ]
}

@test 'cd to dotfiles castle subdirectory' {
	castle 'dotfiles'
	local dotfiles_dir=$HOMESICK/repos/dotfiles/home/.config/foo.conf
	local result=$($HOMESHICK_FN cd dotfiles/home/.config/foo.conf && pwd)
	[ "$dotfiles_dir" = "$result" ]
}

@test 'cd to my_module castle' {
	castle 'module-files'
	$HOMESHICK_FN --batch clone $REPO_FIXTURES/my_module
	local my_module_dir=$HOMESICK/repos/my_module
	local result=$($HOMESHICK_FN cd my_module && pwd)
	[ "$my_module_dir" = "$result" ]
}

@test 'cd to nonexistent castle' {
	local current_dir=$(pwd)
	local result=$($HOMESHICK_FN cd non_existent 2>/dev/null; pwd)
	[ "$current_dir" = "$result" ]
}

@test "cd'ing to nonexistent castle exits with errcode 1" {
	run $HOMESHICK_FN cd non_existent
	[ "$status" -eq 1 ]
}

@test 'cd to castle with spaces in its name' {
	castle 'repo with spaces in name'
	local spaces_repo_dir="$HOMESICK/repos/repo with spaces in name"
	local result=$($HOMESHICK_FN cd repo\ with\ spaces\ in\ name && pwd)
	[ "$spaces_repo_dir" = "$result" ]
}
