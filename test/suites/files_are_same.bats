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

@test 'success if files have same content' {
  cat > "$HOME/file1" <<EOF
    line 1
      line 2
EOF
  cat > "$HOME/file2" <<EOF
    line 1
      line 2
EOF
  files_are_same "$HOME/file1" "$HOME/file2"
}

@test 'success if files have same content, even if one is a symlink' {
  echo 'file contents' > "$HOME/file1"
  echo 'file contents' > "$HOME/file2"
  ln -s "$HOME/file2" "$HOME/file2-link"
  files_are_same "$HOME/file1" "$HOME/file2-link"
}

@test 'fail if contents differ' {
  echo 'file contents' > "$HOME/file1"
  echo 'file content' > "$HOME/file2"
  ! files_are_same "$HOME/file1" "$HOME/file2"
}
