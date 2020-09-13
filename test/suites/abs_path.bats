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

@test 'test simple filepath' {
  touch "$HOME/file"
  local path
  path=$(cd "$HOME" && abs_path file)
  [ "$path" = "$HOME/file" ]
}

@test 'test filepath with spaces' {
  mkdir "$HOME/folder with spaces"
  touch "$HOME/folder with spaces/file"
  local path
  path=$(cd "$HOME" && abs_path folder\ with\ spaces/file)
  [ "$path" = "$HOME/folder with spaces/file" ]
}

@test 'test filepath and filename with spaces' {
  mkdir "$HOME/folder with spaces"
  touch "$HOME/folder with spaces/file name with spaces"
  local path
  path=$(cd "$HOME" && abs_path folder\ with\ spaces/file\ name\ with\ spaces)
  [ "$path" = "$HOME/folder with spaces/file name with spaces" ]
}

@test 'test folder' {
  mkdir "$HOME/folder"
  local path
  path=$(cd "$HOME" && abs_path folder)
  [ "$path" = "$HOME/folder" ]
}

@test 'test subfolder' {
  mkdir -p "$HOME/folder/subfolder"
  local path
  path=$(cd "$HOME" && abs_path folder/subfolder)
  [ "$path" = "$HOME/folder/subfolder" ]
}

@test 'test folders with spaces' {
  mkdir -p "$HOME/folder with spaces/sub folder"
  local path
  path=$(cd "$HOME" && abs_path folder\ with\ spaces/sub\ folder)
  [ "$path" = "$HOME/folder with spaces/sub folder" ]
}

@test 'test root' {
  local path
  path=$(abs_path /)
  [ "$path" = "/" ]
}

@test 'test file in root' {
  local path
  path=$(abs_path /test)
  [ "$path" = "/test" ]
}

@test 'test trailing slash' {
  local path
  path=$(abs_path /test/)
  [ "$path" = "/test" ]
}

@test 'test trailing slashdot' {
  mkdir "$HOME/test"
  local path
  path=$(cd "$HOME" && abs_path test/.)
  [ "$path" = "$HOME/test" ]
}

@test 'test symlink' {
  mkdir "$HOME/realdir"
  ln -s realdir "$HOME/symlink"
  local path
  path=$(cd "$HOME" && abs_path symlink)
  [ "$path" = "$HOME/symlink" ]
}

@test 'test symlink resolution' {
  mkdir "$HOME/realdir"
  ln -s realdir "$HOME/symlink"
  local path
  path=$(cd "$HOME" && abs_path -P symlink/.)
  local abs_home
  abs_home=$(cd "$HOME" >/dev/null && pwd -P)
  [ "$path" = "$abs_home/realdir" ]
}
