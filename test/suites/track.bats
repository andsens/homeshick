#!/usr/bin/env bats

load ../helper

@test 'track absolute path' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[ -f "$HOMESICK/repos/rc-files/home/.zshrc" ]
	[ -L "$HOME/.zshrc" ]
}

@test 'track path with spaces' {
	castle 'rc-files'
	cat > $HOME/.path\ with\ spaces <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.path\ with\ spaces
	[ -f "$HOMESICK/repos/rc-files/home/.path with spaces" ]
	[ -L "$HOME/.path with spaces" ]
}

@test 'track path with spaces (spaces in foldername and filename)' {
	castle 'rc-files'
	mkdir -p $HOME/deep\ folder/structure/with\ spaces
	local file=$HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	cat > "$file" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	[ -f "$HOMESICK/repos/rc-files/home/deep folder/structure/with spaces/.file with spaces" ]
	[ -L "$file" ]
}

@test 'track two paths with spaces' {
	castle 'rc-files'
	mkdir -p $HOME/deep\ folder/structure/with\ spaces
	local file1=$HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	local file2=$HOME/.path\ with\ spaces
	cat > "$file1" <<EOF
homeshick --batch refresh
EOF
	cat > "$file2" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.path\ with\ spaces $HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	[ -f "$HOMESICK/repos/rc-files/home/deep folder/structure/with spaces/.file with spaces" ]
	[ -L "$file1" ]
	[ -f "$HOMESICK/repos/rc-files/home/.path with spaces" ]
	[ -L "$file2" ]
}

@test 'track relative path' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	(cd $HOME; $HOMESHICK_FN track rc-files .zshrc)
	[ -f "$HOMESICK/repos/rc-files/home/.zshrc" ]
	[ -L "$HOME/.zshrc" ]
}

@test 'track in castle with spaces' {
	castle 'repo with spaces in name'
	cat > $HOME/.vimrc <<EOF
My empty vim config
EOF
	(cd $HOME; $HOMESHICK_FN track repo\ with\ spaces\ in\ name .vimrc)
	local file="$HOMESICK/repos/repo with spaces in name/home/.vimrc"
	[ -f "$file" ]
	[ -L "$HOME/.vimrc" ]
}

@test 'disallow tracking outside homedir' {
	castle 'rc-files'
	cat > $NOTHOME/some_other_file <<EOF
homeshick should refuse to track this file
EOF
	run $HOMESHICK_FN track rc-files $NOTHOME/some_other_file
	[ $status -eq 1 ]
	[ -e "$NOTHOME/some_other_file" ]
	[ ! -L "$NOTHOME/some_other_file" ]
	rm $NOTHOME/some_other_file
}

@test 'disallow overwrite when tracking' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[ -L "$HOME/.zshrc" ]
	rm $HOME/.zshrc
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh 7
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	local tracked_file_size=$(stat -c %s $HOMESICK/repos/rc-files/home/.zshrc 2>/dev/null || \
	                          stat -f %z $HOMESICK/repos/rc-files/home/.zshrc)
	[ 26 -eq $tracked_file_size ]
	[ ! -L "$HOME/.zshrc" ]
}

@test 'disallow double tracking' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[ -L "$HOME/.zshrc" ]
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[ ! -L "$HOMESICK/repos/rc-files/home/.zshrc" ]
}

@test 'git add when tracked' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	local git_status=$(cd $HOMESICK/repos/rc-files; git status --porcelain)
	[ "A  home/.zshrc" = "$git_status" ]
}

@test 'track folder' {
	castle 'rc-files'
	mkdir -p $HOME/.somefolder/subfolder/stuff
	touch $HOME/.somefolder/file1
	touch $HOME/.somefolder/subfolder/file2
	touch $HOME/.somefolder/subfolder/file3
	touch $HOME/.somefolder/subfolder/stuff/file4
	$HOMESHICK_FN track rc-files $HOME/.somefolder
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/file1" ]
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/subfolder/file2" ]
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/subfolder/file3" ]
	[ -e "$HOMESICK/repos/rc-files/home/.somefolder/subfolder/stuff/file4" ]
}

@test "don't track ignored file" {
	castle 'rc-files'
	mkdir $HOME/.folder
	touch $HOME/.folder/somefile.swp
	$HOMESHICK_FN track rc-files $HOME/.folder/somefile.swp
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/somefile.swp" ]
}

@test "don't track ignored files in folder" {
	castle 'rc-files'
	mkdir $HOME/.folder
	touch $HOME/.folder/somefile.swp
	touch $HOME/.folder/trackthisthough
	$HOMESHICK_FN track rc-files $HOME/.folder/
	[ ! -e "$HOMESICK/repos/rc-files/home/.folder/somefile.swp" ]
	[ -e "$HOMESICK/repos/rc-files/home/.folder/trackthisthough" ]
}

@test 'track folder with spaces in name' {
	castle 'rc-files'
	mkdir -p $HOME/.some\ folder/sub\ folder/stuff
	touch $HOME/.some\ folder/file
	touch $HOME/.some\ folder/sub\ folder/stuff/other\ file
	$HOMESHICK_FN track rc-files $HOME/.some\ folder
	[ -e "$HOMESICK/repos/rc-files/home/.some folder/file" ]
	[ -e "$HOMESICK/repos/rc-files/home/.some folder/sub folder/stuff/other file" ]
}


@test 'track with globbing' {
	castle 'rc-files'
	mkdir -p $HOME/.folder/subfolder $HOME/.folder/subfolder2
	touch $HOME/.folder/ignored.swp
	touch $HOME/.folder/notglobbed.bash
	touch $HOME/.folder/globbed2.exclude
	touch $HOME/.folder/subfolder/this_as_well.bash
	touch $HOME/.folder/subfolder2/and_this.bash
	$HOMESHICK_FN track rc-files $HOME/.folder/**/*.bash
	[ ! -e $HOMESICK/repos/rc-files/home/.folder/ignored.swp ]
	[ ! -e $HOMESICK/repos/rc-files/home/.folder/notglobbed.bash ]
	[ ! -e $HOMESICK/repos/rc-files/home/.folder/globbed2.exclude ]
	[ -e $HOMESICK/repos/rc-files/home/.folder/subfolder/this_as_well.bash ]
	[ -e $HOMESICK/repos/rc-files/home/.folder/subfolder2/and_this.bash ]
}

@test 'track file in new folder with git version >= 1.8.2' {
	castle 'rc-files'
	GIT_VERSION=$(git --version | grep 'git version' | cut -d ' ' -f 3)
	[[ ! $GIT_VERSION =~ ([0-9]+)(\.[0-9]+){0,3} ]] && skip 'could not detect git version'
	run version_compare $GIT_VERSION 1.8.2
	[[ $? == 2 ]] && skip 'git version too low'

	mkdir $HOME/.folder
	touch $HOME/.folder/ignored.swp
	$HOMESHICK_FN track rc-files $HOME/.folder/ignored.swp
	[ ! -e $HOMESICK/repos/rc-files/home/.folder/ignored.swp ]
	[ ! -e $HOMESICK/repos/rc-files/home/.folder ]
}

@test 'track file in new folder with mocked git version < 1.8.2' {
	castle 'rc-files'
	mock_git_version 1.8.0

	mkdir $HOME/.folder
	touch $HOME/.folder/ignored.swp
	$HOMESHICK_FN track rc-files $HOME/.folder/ignored.swp
	[ ! -e $HOMESICK/repos/rc-files/home/.folder/ignored.swp ]
	[ -e $HOMESICK/repos/rc-files/home/.folder ]
}

@test 'track should create link with same access permissions as file' {
	castle 'rc-files'
	file=$HOMESICK/repos/rc-files/home/.zshrc
	link=$HOME/.zshrc
	cat > $link <<EOF
homeshick --batch refresh
EOF
	chmod 0600 $link
	$HOMESHICK_FN track rc-files $HOME/.zshrc

	is_symlink $file $link
	file_octal=$(octal_access $file)
	link_octal=$(octal_access $link)
	[ $link_octal = $file_octal ]
}
