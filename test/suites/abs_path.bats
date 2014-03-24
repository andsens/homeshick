#!/usr/bin/env bats

load ../helper

function setup() {
	setup_env
	source $HOMESICK/repos/homeshick/utils/fs.sh
}

@test 'test simple filepath' {
	touch $HOME/file
	local path=$(cd $HOME && abs_path file)
	[ "$path" = "$HOME/file" ]
}

@test 'test filepath with spaces' {
	mkdir $HOME/folder\ with\ spaces
	touch $HOME/folder\ with\ spaces/file
	local path=$(cd $HOME && abs_path folder\ with\ spaces/file)
	[ "$path" = "$HOME/folder with spaces/file" ]
}

@test 'test filepath and filename with spaces' {
	mkdir $HOME/folder\ with\ spaces
	touch $HOME/folder\ with\ spaces/file\ name\ with\ spaces
	local path=$(cd $HOME && abs_path folder\ with\ spaces/file\ name\ with\ spaces)
	[ "$path" = "$HOME/folder with spaces/file name with spaces" ]
}

@test 'test folder' {
	mkdir $HOME/folder
	local path=$(cd $HOME && abs_path folder)
	[ "$path" = "$HOME/folder" ]
}

@test 'test subfolder' {
	mkdir -p $HOME/folder/subfolder
	local path=$(cd $HOME && abs_path folder/subfolder)
	[ "$path" = "$HOME/folder/subfolder" ]
}

@test 'test folders with spaces' {
	mkdir -p $HOME/folder\ with\ spaces/sub\ folder
	local path=$(cd $HOME && abs_path folder\ with\ spaces/sub\ folder)
	[ "$path" = "$HOME/folder with spaces/sub folder" ]
}
