#!/usr/bin/env bats

load ../helper.sh

setup() {
  create_test_dir
  # shellcheck source=../../lib/fs.sh
  source "$HOMESHICK_DIR/lib/fs.sh"
}

teardown() {
  delete_test_dir
}

test_rel_path() {
  local source_dir=$1
  local target=$2
  local expected=$3
  local link
  link=$(create_rel_path "$source_dir" "$target")
  if [[ $link != "$expected" ]]; then
    printf "got '%s'\n" "$link"
    [ "$expected" = "$link" ]
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

@test 'fail on non existent source_dir' {
  run create_rel_path "$HOME/dir/dir2" "$HOME/file"
  [ $status -eq 1 ]
}

@test 'relpath from inside symlinked dir on same level as real dir to file' {
  mkdir -p "$HOME/realdir"
  ln -s "realdir" "$HOME/symlinkdir"
  touch "$HOME/file"
  test_rel_path "$HOME/symlinkdir/" "$HOME/file" "../file"
}

@test 'relpath from inside symlinked dir on higher level than real dir to file' {
  mkdir -p "$HOME/somedir/realdir"
  ln -s "somedir/realdir" "$HOME/symlinkdir"
  touch "$HOME/file"
  test_rel_path "$HOME/symlinkdir/" "$HOME/file" "../../file"
}

@test 'relpath from inside symlinked dir on higher level than real dir to file where root dir is symlinked dir' {
  mkdir "$HOME/root"
  ln -s "root" "$HOME/symlinked-root"
  mkdir -p "$HOME/symlinked-root/somedir/realdir"
  ln -s "somedir/realdir" "$HOME/symlinked-root/symlinkdir"
  touch "$HOME/symlinked-root/file"
  test_rel_path "$HOME/symlinked-root/symlinkdir/" "$HOME/symlinked-root/file" "../../file"
}
