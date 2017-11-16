#!/usr/bin/env bats

load ../helper

function setup() {
	setup_env
	source "$HOMESHICK_DIR/lib/fs.sh"
}

function test_rel_path() {
	local source_dir=$1
	local target=$2
	local expected=$3
	local link
	link=$(create_rel_path "$source_dir" "$target")
	if [[ $link != "$expected" ]]; then
		printf "got '%s'\n" "$link"
		[ "$expected" = "$cleaned" ]
	fi
}

@test 'relpath from . to file' {
	touch "$HOME/file"
	test_rel_path "$HOME/" "$HOME/file" "file"
}

@test 'relpath from folder/ to file' {
	mkdir "$HOME/folder"
	touch "$HOME/file"
	test_rel_path "$HOME/folder/" "$HOME/file" "../file"
}

@test 'relpath from folder1/ to folder2/file' {
	mkdir "$HOME/folder1" "$HOME/folder2"
	touch "$HOME/folder2/file"
	test_rel_path "$HOME/folder1/" "$HOME/folder2/file" "../folder2/file"
}

@test 'relpath from lvl1/lvl2/lvl3/ to lvl1-2/file' {
	mkdir -p "$HOME/lvl1/lvl2/lvl3" "$HOME/lvl1-2"
	touch "$HOME/lvl1-2/file"
	test_rel_path "$HOME/lvl1/lvl2/lvl3/" "$HOME/lvl1-2/file" "../../../lvl1-2/file"
}

@test 'relpath from lvl1-2/ to lvl1/lvl2/lvl3/file' {
	mkdir -p "$HOME/lvl1/lvl2/lvl3" "$HOME/lvl1-2"
	touch "$HOME/lvl1/lvl2/lvl3/file"
	test_rel_path "$HOME/lvl1-2/" "$HOME/lvl1/lvl2/lvl3/file" "../lvl1/lvl2/lvl3/file"
}

@test 'relpath from dir/ non-existent-file' {
	run create_rel_path "$HOME/dir" "$HOME/non-existent-file" "non-existent-file"
}

@test 'relpath from dir/ dir2/non-existent-file' {
	run create_rel_path "$HOME/dir" "$HOME/dir2/non-existent-file" "dir2/non-existent-file"
}
