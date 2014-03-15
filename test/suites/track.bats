#!/usr/bin/env bats

load ../helper

@test 'track absolute path' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[[ -f $HOMESICK/repos/rc-files/home/.zshrc ]]
	[[ -L $HOME/.zshrc ]]
}

@test 'track path with spaces' {
	castle 'rc-files'
	cat > $HOME/.path\ with\ spaces <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.path\ with\ spaces
	[[ -f $HOMESICK/repos/rc-files/home/.path\ with\ spaces ]]
	[[ -L $HOME/.path\ with\ spaces ]]
}

@test 'track path with spaces (spaces in foldername and filename)' {
	castle 'rc-files'
	mkdir -p $HOME/deep\ folder/structure/with\ spaces
	local file=$HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	cat > "$file" <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/deep\ folder/structure/with\ spaces/.file\ with\ spaces
	[[ -f $HOMESICK/repos/rc-files/home/deep\ folder/structure/with\ spaces/.file\ with\ spaces ]]
	[[ -L $file ]]
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
	[[ -f $HOMESICK/repos/rc-files/home/deep\ folder/structure/with\ spaces/.file\ with\ spaces ]]
	[[ -L $file1 ]]
	[[ -f $HOMESICK/repos/rc-files/home/.path\ with\ spaces ]]
	[[ -L $file2 ]]
}

@test 'track relative path' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	(cd $HOME; $HOMESHICK_FN track rc-files .zshrc)
	[[ -f $HOMESICK/repos/rc-files/home/.zshrc ]]
	[[ -L $HOME/.zshrc ]]
}

@test 'track in castle with spaces' {
	castle 'repo with spaces in name'
	cat > $HOME/.vimrc <<EOF
My empty vim config
EOF
	(cd $HOME; $HOMESHICK_FN track repo\ with\ spaces\ in\ name .vimrc)
	local file="$HOMESICK/repos/repo with spaces in name/home/.vimrc"
	[[ -f $file ]]
	[[ -L $HOME/.vimrc ]]
}

@test 'disallow tracking outside homedir' {
	castle 'rc-files'
	cat > $NOTHOME/some_other_file <<EOF
homeshick should refuse to track this file
EOF
	run $HOMESHICK_FN track rc-files $NOTHOME/some_other_file
	[[ $status == 1 ]]
	[[ -e $NOTHOME/some_other_file ]]
	[[ ! -L $NOTHOME/some_other_file ]]
	rm $NOTHOME/some_other_file
}

@test 'disallow overwrite when tracking' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[[ -L $HOME/.zshrc ]]
	rm $HOME/.zshrc
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh 7
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	local tracked_file_size=$(stat -c %s $HOMESICK/repos/rc-files/home/.zshrc 2>/dev/null || \
	                          stat -f %z $HOMESICK/repos/rc-files/home/.zshrc)
	[[ 26 == $tracked_file_size ]]
	[[ ! -L $HOME/.zshrc ]]
}

@test 'disallow double tracking' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[[ -L $HOME/.zshrc ]]
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	[[ ! -L $HOMESICK/repos/rc-files/home/.zshrc ]]
}

@test 'git add when tracked' {
	castle 'rc-files'
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_FN track rc-files $HOME/.zshrc
	local git_status=$(cd $HOMESICK/repos/rc-files; git status --porcelain)
	[[ "A  home/.zshrc" == "$git_status" ]]
}
