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

@test 'cd to castle in sh' {
	[ $(type -t sh) = "file" ] || skip "sh not installed"
	castle 'dotfiles'
	local dotfiles_dir=$HOMESICK/repos/dotfiles
	cmd=". $HOMESHICK_FN_SRC_SH && $HOMESHICK_FN cd dotfiles && echo \$PWD"
	local result=$( sh <<< "$cmd" 2>&1 )
	[ "$dotfiles_dir" = "$result" ]
}

@test 'cd to castle in dash' {
	[ $(type -t dash) = "file" ] || skip "dash not installed"
	castle 'dotfiles'
	local dotfiles_dir=$HOMESICK/repos/dotfiles
	cmd=". $HOMESHICK_FN_SRC_SH && $HOMESHICK_FN cd dotfiles && echo \$PWD"
	local result=$( dash <<< "$cmd" 2>&1 )
	[ "$dotfiles_dir" = "$result" ]
}

@test 'cd to castle in csh' {
	[ $(type -t csh) = "file" ] || skip "csh not installed"
	$EXPECT_INSTALLED || skip 'expect not installed'
	# in csh we can't alias a command and use that command on the same line
	# % do_something; do_something_else
	# is apparently different from
	# % do_something
	# % do_something_else
	castle 'dotfiles'
	local dotfiles_dir=$HOMESICK/repos/dotfiles
	cat <<EOF | expect -f -
			spawn csh
			send "alias $HOMESHICK_FN source \"$HOMESHICK_FN_SRC_CSH\"\n"
			send "$HOMESHICK_FN cd dotfiles\n"
			send "pwd\n"
			expect "*$dotfiles_dir*" {} default {exit 1}
			send "exit\n"
			expect EOF
EOF
}

@test 'cd to castle in fish' {
	[ $(type -t fish) = "file" ] || skip "fish not installed"
	castle 'dotfiles'
	# fish $PWD has all symlinks resolved
	local dotfiles_dir=$(cd $HOMESICK/repos/dotfiles && pwd -P)
	cmd="source $HOMESHICK_FN_SRC_FISH; and $HOMESHICK_FN cd dotfiles; and pwd"
	local result=$( fish <<< "$cmd" 2>&1 )
	[ "$dotfiles_dir" = "$result" ]
}
