#!/usr/bin/env bats

load ../helper

@test 'track non-existent file' {
	castle 'symlinks'
	run "$HOMESHICK_FN" track symlinks "$HOME/non-existent-file"
	[ $status -eq 1 ] # EX_ERR
}

@test 'track relative symlink in $HOME' {
	castle 'symlinks'
	echo "test" > "$HOME/some_file"
	(cd "$HOME" && ln -s some_file link_to_some_file)
	$HOMESHICK_FN track symlinks "$HOME/link_to_some_file"
	[ "$(cat "$HOME/link_to_some_file")" = 'test' ]
	is_symlink ../../../../some_file "$HOMESICK/repos/symlinks/home/link_to_some_file"
}

@test 'track absolute symlink' {
	castle 'symlinks'
	echo "test" > "$HOME/some_file"
	(cd "$HOME" && ln -s "$HOME/some_file" link_to_some_file)
	$HOMESHICK_FN track symlinks "$HOME/link_to_some_file"
	[ "$(cat "$HOME/link_to_some_file")" = 'test' ]
	is_symlink "$HOME/some_file" "$HOMESICK/repos/symlinks/home/link_to_some_file"
}

@test 'track relative symlink in deep folder structure to file outside $HOME' {
	castle 'symlinks'
	mkdir -p "$NOTHOME/some/folder/outside/home"
	echo "test" > "$NOTHOME/some/folder/outside/home/some_file"
	mkdir -p "$HOME/somedir/someotherdir/deep"
	(cd "$HOME" && ln -s ../../../../nothome/some/folder/outside/home/some_file "$HOME/somedir/someotherdir/deep/link_to_some_file")
	$HOMESHICK_FN track symlinks "$HOME/somedir/someotherdir/deep/link_to_some_file"
	[ "$(cat "$HOME/somedir/someotherdir/deep/link_to_some_file")" = 'test' ]
	local relpath='../../../../../../../../nothome/some/folder/outside/home/some_file'
	is_symlink "$relpath" "$HOMESICK/repos/symlinks/home/somedir/someotherdir/deep/link_to_some_file"
}

@test 'track relative snakelike symlink' {
	castle 'symlinks'
	mkdir -p "$HOME/some/folder"
	mkdir -p "$HOME/someother/folder"
	echo "test" > "$HOME/someother/folder/some_file"
	mkdir -p "$HOME/somethird/folder"
	(cd "$HOME" && ln -s ../../some/folder/../../someother/folder/some_file "$HOME/somethird/folder/link_to_some_file")
	$HOMESHICK_FN track symlinks "$HOME/somethird/folder/link_to_some_file"
	[ "$(cat "$HOME/somethird/folder/link_to_some_file")" = 'test' ]
	local relpath='../../../../../../someother/folder/some_file'
	is_symlink "$relpath" "$HOMESICK/repos/symlinks/home/somethird/folder/link_to_some_file"
}

@test 'track dead symlink' {
	castle 'symlinks'
	(cd "$HOME" && ln -s some_file link_to_some_file)
	$HOMESHICK_FN track symlinks "$HOME/link_to_some_file"
	[ ! -e "$HOME/link_to_some_file" ]
	is_symlink ../../../../some_file "$HOMESICK/repos/symlinks/home/link_to_some_file"
}

@test 'track absolute path' {
	castle 'rc-files'
	cat > "$HOME/.zshrc" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files "$HOME/.zshrc"
	[ -f "$HOMESICK/repos/rc-files/home/.zshrc" ]
	[ -L "$HOME/.zshrc" ]
}

@test 'track path with spaces' {
	castle 'rc-files'
	cat > "$HOME/.path with spaces" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files "$HOME/.path with spaces"
	[ -f "$HOMESICK/repos/rc-files/home/.path with spaces" ]
	[ -L "$HOME/.path with spaces" ]
}

@test 'track path with spaces (spaces in foldername and filename)' {
	castle 'rc-files'
	mkdir -p "$HOME/deep folder/structure/with spaces"
	local file="$HOME/deep folder/structure/with spaces/.file with spaces"
	cat > "$file" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files "$HOME/deep folder/structure/with spaces/.file with spaces"
	[ -f "$HOMESICK/repos/rc-files/home/deep folder/structure/with spaces/.file with spaces" ]
	[ -L "$file" ]
}

@test 'track two paths with spaces' {
	castle 'rc-files'
	mkdir -p "$HOME/deep folder/structure/with spaces"
	local file1="$HOME/deep folder/structure/with spaces/.file with spaces"
	local file2="$HOME/.path with spaces"
	cat > "$file1" <<EOF
homeshick --batch refresh
EOF
	cat > "$file2" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files "$HOME/.path with spaces" "$HOME/deep folder/structure/with spaces/.file with spaces"
	[ -f "$HOMESICK/repos/rc-files/home/deep folder/structure/with spaces/.file with spaces" ]
	[ -L "$file1" ]
	[ -f "$HOMESICK/repos/rc-files/home/.path with spaces" ]
	[ -L "$file2" ]
}

@test 'track relative path' {
	castle 'rc-files'
	cat > "$HOME/.zshrc" <<EOF
homeshick --batch refresh
EOF
	(cd "$HOME" && $HOMESHICK_FN track rc-files .zshrc)
	[ -f "$HOMESICK/repos/rc-files/home/.zshrc" ]
	[ -L "$HOME/.zshrc" ]
}

@test 'track in castle with spaces' {
	castle 'repo with spaces in name'
	cat > "$HOME/.vimrc" <<EOF
My empty vim config
EOF
	(cd "$HOME" && $HOMESHICK_FN track repo\ with\ spaces\ in\ name .vimrc)
	local file="$HOMESICK/repos/repo with spaces in name/home/.vimrc"
	[ -f "$file" ]
	[ -L "$HOME/.vimrc" ]
}

@test 'disallow tracking outside homedir' {
	castle 'rc-files'
	cat > "$NOTHOME/some_other_file" <<EOF
homeshick should refuse to track this file
EOF
	run "$HOMESHICK_FN" track rc-files "$NOTHOME/some_other_file"
	[ $status -eq 1 ]
	[ -e "$NOTHOME/some_other_file" ]
	[ ! -L "$NOTHOME/some_other_file" ]
	rm "$NOTHOME/some_other_file"
}

@test 'disallow overwrite when tracking' {
	castle 'rc-files'
	cat > "$HOME/.zshrc" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files "$HOME/.zshrc"
	[ -L "$HOME/.zshrc" ]
	rm "$HOME/.zshrc"
	cat > "$HOME/.zshrc" <<EOF
homeshick --batch refresh 7
EOF
	$HOMESHICK_FN track rc-files "$HOME/.zshrc"
	local tracked_file_size
	tracked_file_size=$(stat -c %s "$HOMESICK/repos/rc-files/home/.zshrc" 2>/dev/null || \
	                    stat -f %z "$HOMESICK/repos/rc-files/home/.zshrc")
	[ 26 -eq "$tracked_file_size" ]
	[ ! -L "$HOME/.zshrc" ]
}

@test 'disallow double tracking' {
	castle 'rc-files'
	cat > "$HOME/.zshrc" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files "$HOME/.zshrc"
	[ -L "$HOME/.zshrc" ]
	$HOMESHICK_FN track rc-files "$HOME/.zshrc"
	[ ! -L "$HOMESICK/repos/rc-files/home/.zshrc" ]
}

@test 'git add when tracked' {
	castle 'rc-files'
	cat > "$HOME/.zshrc" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files "$HOME/.zshrc"
	local git_status
	git_status=$(cd "$HOMESICK/repos/rc-files" && git status --porcelain)
	[ "A  home/.zshrc" = "$git_status" ]
}

@test 'track folder' {
	castle 'rc-files'
	mkdir -p "$HOME/.somefolder/subfolder/stuff"
	touch "$HOME/.somefolder/file1"
	touch "$HOME/.somefolder/subfolder/file2"
	touch "$HOME/.somefolder/subfolder/file3"
	touch "$HOME/.somefolder/subfolder/stuff/file4"
	$HOMESHICK_FN track rc-files "$HOME/.somefolder"
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/file1" ]
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/subfolder/file2" ]
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/subfolder/file3" ]
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/subfolder/stuff/file4" ]
}

@test "don't track ignored file" {
	castle 'rc-files'
	mkdir "$HOME/.folder"
	touch "$HOME/.folder/somefile.swp"
	$HOMESHICK_FN track rc-files "$HOME/.folder/somefile.swp"
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/somefile.swp" ]
}

@test "don't track ignored files in folder" {
	castle 'rc-files'
	mkdir "$HOME/.folder"
	touch "$HOME/.folder/somefile.swp"
	touch "$HOME/.folder/trackthisthough"
	$HOMESHICK_FN track rc-files "$HOME/.folder/"
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/somefile.swp" ]
	[ -e "$HOMESICK/repos/rc-files/home/.folder/trackthisthough" ]
}

@test 'track folder with spaces in name' {
	castle 'rc-files'
	mkdir -p "$HOME/.some folder/sub folder/stuff"
	touch "$HOME/.some folder/file"
	touch "$HOME/.some folder/sub folder/stuff/other file"
	$HOMESHICK_FN track rc-files "$HOME/.some folder"
	[ -e "$HOMESICK/repos/rc-files/home/.some folder/file" ]
	[ -e "$HOMESICK/repos/rc-files/home/.some folder/sub folder/stuff/other file" ]
}

@test 'track with globbing' {
	castle 'rc-files'
	mkdir -p "$HOME/.folder/subfolder" "$HOME/.folder/subfolder2"
	touch "$HOME/.folder/ignored.swp"
	touch "$HOME/.folder/notglobbed.bash"
	touch "$HOME/.folder/globbed2.exclude"
	touch "$HOME/.folder/subfolder/this_as_well.bash"
	touch "$HOME/.folder/subfolder2/and_this.bash"
	$HOMESHICK_FN track rc-files "$HOME/.folder"/**/*.bash
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/ignored.swp" ]
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/notglobbed.bash" ]
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/globbed2.exclude" ]
	[ -e "$HOMESICK/repos/rc-files/home/.folder/subfolder/this_as_well.bash" ]
	[ -e "$HOMESICK/repos/rc-files/home/.folder/subfolder2/and_this.bash" ]
}

@test 'track file in new folder with git version >= 1.8.2' {
	GIT_VERSION=$(git --version | grep 'git version' | cut -d ' ' -f 3)
	[[ ! $GIT_VERSION =~ ([0-9]+)(\.[0-9]+){0,3} ]] && skip 'could not detect git version'
	run version_compare "$GIT_VERSION" 1.8.2
	[[ $status == 2 ]] && skip 'git version too low'

	castle 'rc-files'
	mkdir "$HOME/.folder"
	touch "$HOME/.folder/ignored.swp"
	$HOMESHICK_FN track rc-files "$HOME/.folder/ignored.swp"
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/ignored.swp" ]
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder" ]
}

@test 'track file in new folder with mocked git version < 1.8.2' {
	# git > 2.3 exits with $?=1 when trying to track an ignored file.
	# In lower versions this was 128, so the homeshick fallback check
	# will not work.
	# This is not a problem, it simply means that we can not emulate
	# git < 1.8.2 behavior with git > 2.3.0 and must skip the test.
	GIT_VERSION=$(git --version | grep 'git version' | cut -d ' ' -f 3)
	[[ ! $GIT_VERSION =~ ([0-9]+)(\.[0-9]+){0,3} ]] && skip 'could not detect git version'
	run version_compare "$GIT_VERSION" 2.3.0
	[[ $status -lt 2 ]] && skip 'git version too high'

	castle 'rc-files'

	mkdir "$HOME/.folder"
	touch "$HOME/.folder/ignored.swp"
	GIT_VERSION=1.8.0 $HOMESHICK_FN track rc-files "$HOME/.folder/ignored.swp"
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/ignored.swp" ]
	[ -e "$HOMESICK/repos/rc-files/home/.folder" ]
}

@test 'track symlink in $HOME to $HOME' {
	castle 'symlinks'
	ln -s . .home
	(cd "$HOME" && ln -s . .home)
	$HOMESHICK_FN track symlinks "$HOME/.home"
	is_symlink ../../../.. "$HOMESICK/repos/symlinks/home/.home"
}

@test 'track file pointing at hidden dir outside home' {
	castle 'symlinks'
	mkdir "$NOTHOME/..some"
	ln -s ../nothome/..some/file "$HOME/.test"
	$HOMESHICK_FN track symlinks "$HOME/.test"
	is_symlink ../../../../../nothome/..some/file "$HOMESICK/repos/symlinks/home/.test"
}

@test 'track file pointing at hidden dir in snakelike fashion' {
	castle 'symlinks'
	ln -s .some/../.file "$HOME/.test"
	$HOMESHICK_FN track symlinks "$HOME/.test"
	is_symlink ../../../../.file "$HOMESICK/repos/symlinks/home/.test"
}

@test 'track regular file from a dir that is a symlink' {
	castle 'symlinks'
	mkdir -p "$HOME/two-levels/under-home"
	ln -s "two-levels/under-home" "$HOME/symlinked-dir"
	touch "$HOME/symlinked-dir/trackme"
	$HOMESHICK_FN track symlinks "$HOME/symlinked-dir/trackme"
	is_symlink ../../.homesick/repos/symlinks/home/symlinked-dir/trackme "$HOME/symlinked-dir/trackme"
}

@test 'track relative symlink from a dir that is a symlink' {
	castle 'symlinks'
	mkdir -p "$HOME/two-levels/under-home"
	ln -s "two-levels/under-home" "$HOME/symlinked-dir"
	touch "$HOME/linktome"
	ln -s "../linktome" "$HOME/symlinked-dir/trackme"
	$HOMESHICK_FN track symlinks "$HOME/symlinked-dir/trackme"
	is_symlink ../../../../../linktome "$HOMESICK/repos/symlinks/home/symlinked-dir/trackme"
	is_symlink ../../.homesick/repos/symlinks/home/symlinked-dir/trackme "$HOME/symlinked-dir/trackme"
}
