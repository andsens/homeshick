#!/usr/bin/env bats

load ../helper

@test 'link file with crazy name' {
	castle 'repo with spaces in name'
	$HOMESHICK_FN --batch link 'repo with spaces in name'
	test_filename=".crazy
file␇☺"
	[ -f "$HOME/.crazy
file␇☺" ]
}

@test 'do not fail when linking file with newline' {
 castle 'rc-files'
 test_filename="filename
newline"
 touch "$HOMESICK/repos/rc-files/home/$test_filename"
 commit_repo_state $HOMESICK/repos/rc-files
 $HOMESHICK_FN --batch link rc-files
 [ -L "$HOME/filename
newline" ]
 is_symlink "$HOMESICK/repos/rc-files/home/filename
newline" "$HOME/filename
newline"
}

@test 'link a file with spaces in its name' {
	castle 'repo with spaces in name'
	$HOMESHICK_FN --batch link "repo with spaces in name"
	[ -f "$HOME/.file with spaces in name" ]
	[ -f "$HOME/.folder with spaces in name/another file with spaces in its name" ]
}

@test 'only link submodule files inside home/' {
	castle 'submodule-outside-home'
	# '!' inverts the return value
	! $HOMESHICK_FN --batch link submodule-outside-home 2>&1 | grep 'No such file or directory'
	# This is the best I can do for testing.
	# The failure does not cause any files to be created
	# Ostensibly homeshick should exit with $? != 0 when linking fails, but it doesn't
}

@test 'link files of nested submodules' {
	fixture 'nested-submodules'
	GIT_VERSION=$(get_git_version)
	run version_compare $GIT_VERSION 1.6.5
	[[ $status == 2 ]] && skip 'git version too low'

	$HOMESHICK_FN --batch clone $REPO_FIXTURES/nested-submodules
	$HOMESHICK_FN --batch link nested-submodules
	[ -f "$HOME/.subdir1/.subdir2/.info2" ]
}

@test "don't fail when linking uninitialized subrepos" {
	fixture 'nested-submodules'
	GIT_VERSION=$(get_git_version)
	run version_compare $GIT_VERSION 1.6.5
	[[ $status == 2 ]] && skip 'git version too low'

	git clone "$REPO_FIXTURES/nested-submodules" "$HOMESICK/repos/nested-submodules"
	[ -f "$HOMESICK/repos/nested-submodules/info" ]
	$HOMESHICK_FN --batch link nested-submodules
	[ ! -f "$HOMESICK/repos/nested-submodules/home/.info" ]
	[ ! -f "$HOME/.info" ]
}

@test 'link submodule files' {
	fixture 'nested-submodules'
	GIT_VERSION=$(get_git_version)
	run version_compare $GIT_VERSION 1.6.5
	[[ $status == 2 ]] && skip 'git version too low'

	$HOMESHICK_FN --batch clone $REPO_FIXTURES/nested-submodules
	$HOMESHICK_FN --batch link nested-submodules
	[ -f "$HOME/.info" ]
	[ -f "$HOME/.subdir1/.info1" ]
}

@test 'link repo with no dirs in home/' {
	castle 'nodirs'
	$HOMESHICK_FN --batch link nodirs
	[ -f "$HOME/.file1" ]
}

@test 'create file-less parent directories' {
	castle 'dotfiles'
	$HOMESHICK_FN --batch link dotfiles
	[ -d "$HOME/.config/foo/bar" ]
}

@test 'symlink to a relative symlink' {
	castle 'symlinks'
	echo "test" > $HOME/file_in_homedir
	$HOMESHICK_FN --batch link symlinks
	[ "$(cat $HOME/link_to_homedir_file)" = 'test' ]
}

@test 'overwrite prompt skipped when linking and --batch is on' {
	castle 'rc-files'
	touch $HOME/.bashrc
	$HOMESHICK_FN --batch link rc-files
	[ -f "$HOME/.bashrc" -a ! -L "$HOME/.bashrc" ]
}

@test 'overwrite file with link when the prompt is answered with yes' {
	$EXPECT_INSTALLED || skip 'expect not installed'

	castle 'rc-files'
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	touch $HOME/.bashrc
	cat <<EOF | expect -f -
			spawn $HOMESHICK_BIN link rc-files
			expect -ex "${esc}1;37m     conflict${esc}0m .bashrc exists\r
${esc}1;36m   overwrite?${esc}0m ${open_bracket}yN${close_bracket}"
			send "y\n"
			expect EOF
EOF
	[ -L "$HOME/.bashrc" ]
}

@test "don't overwrite file or prompt for it when linking and --skip is on" {
	castle 'rc-files'
	touch $HOME/.bashrc
	$HOMESHICK_FN --skip link rc-files
	[ -f "$HOME/.bashrc" -a ! -L "$HOME/.bashrc" ]
}

@test 'existing symlinks are not relinked when running link' {
	castle 'module-files'
	$HOMESHICK_FN --batch link module-files
	local inode_before=$(get_inode_no $HOME/.my_module)
	$HOMESHICK_FN --batch link module-files
	local inode_after=$(get_inode_no $HOME/.my_module)
	[ "$inode_before" -eq "$inode_after" ]
}

@test 'traverse into the folder structure when linking' {
	castle 'dotfiles'
	mkdir -p $HOME/.config/bar.dir
	cat > $HOME/.config/foo.conf <<EOF
#I am just a regular foo.conf file
[foo]
A=True
EOF
	cat > $HOME/.config/bar.dir/bar.conf <<EOF
#I am just a regular bar.conf file
[bar]
A=True
EOF

	[ -f "$HOME/.config/foo.conf" ]
	#.config/foo.conf should be overwritten by a directory of the same name
	[ -d "$HOME/.config/bar.dir" ]
	#.config/bar.dir should be overwritten by a file of the same name
	$HOMESHICK_FN --batch --force link dotfiles
	[ -d "$HOME/.config/foo.conf" ]
	[ -f "$HOME/.config/bar.dir" ]
}

@test 'treat symlinked directories in the castle like files when linking' {
	castle 'module-files'
	$HOMESHICK_FN --batch link module-files
	[ -L "$HOME/.my_module" ]
}

@test '.git directories are not symlinked' {
	castle 'dotfiles'
	$HOMESHICK_FN --batch link dotfiles
	[ ! -e "$HOME/.vim/.git" ]
}

@test 'link a castle with spaces in its name' {
	castle 'repo with spaces in name'
	$HOMESHICK_FN --batch link repo\ with\ spaces\ in\ name
	[ -f "$HOME/.repowithspacesfile" ]
}

@test 'pass multiple castlenames to link' {
	castle 'rc-files'
	castle 'dotfiles'
	castle 'repo with spaces in name'
	$HOMESHICK_FN --batch link rc-files dotfiles repo\ with\ spaces\ in\ name
	is_symlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
	is_symlink $HOMESICK/repos/dotfiles/home/.ssh/known_hosts $HOME/.ssh/known_hosts
	is_symlink "$HOMESICK/repos/repo with spaces in name/home/.repowithspacesfile" $HOME/.repowithspacesfile
}

@test 'link all castles when no castle is specified' {
	castle 'rc-files'
	castle 'dotfiles'
	castle 'repo with spaces in name'
	$HOMESHICK_FN --batch link
	is_symlink $HOMESICK/repos/rc-files/home/.bashrc $HOME/.bashrc
	is_symlink $HOMESICK/repos/dotfiles/home/.ssh/known_hosts $HOME/.ssh/known_hosts
	is_symlink "$HOMESICK/repos/repo with spaces in name/home/.repowithspacesfile" $HOME/.repowithspacesfile
}

@test 'files ignored by git should not be linked' {
	castle 'dotfiles'
	touch "$HOMESICK/repos/dotfiles/home/shouldBeIgnored.txt"
	cat > $HOMESICK/repos/dotfiles/.gitignore <<EOF
shouldBeIgnored.txt
EOF
	commit_repo_state $HOMESICK/repos/dotfiles
	$HOMESHICK_FN --batch link dotfiles
	[ ! -L "$HOME/shouldBeIgnored.txt" ]
}
