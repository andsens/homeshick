#!/usr/bin/env bats

load ../helper.sh

setup() {
  create_test_dir
  # shellcheck source=../../homeshick.sh
  source "$HOMESHICK_DIR/homeshick.sh"
}

teardown() {
  delete_test_dir
}

@test 'invoke non existing command' {
  run homeshick commandthatdoesnexist
  [ $status -eq 64 ] # EX_USAGE
}

@test 'verbose mode should print identical messages when linking' {
  castle 'symlinks'
  homeshick link symlinks
  homeshick -v link symlinks | grep identical
}

@test 'normal verbosity should not print identical messages when linking' {
  castle 'symlinks'
  homeshick link symlinks
  ! homeshick link symlinks | grep -q identical
}

@test 'link non-existent castle' {
  run homeshick link nonexistent
  [ $status -eq 1 ] # EX_ERR
}

@test 'error should end with a single newline' {
  homeshick --batch generate existing-repo
  output=$(homeshick --batch generate existing-repo 2>&1 | tr '\n' 'n')
  run grep -q 'nn$' <<<"$output"
  [ $status -eq 1 ]
}

@test 'fish function should not print errors when invoked without arguments' {
  [ "$(type -t fish)" = "file" ] || skip "fish not installed"
  cmd="source \"$HOMESHICK_DIR/homeshick.fish\"; and homeshick"
  local stderr
  stderr=$( fish <<< "$cmd" 2>&1 >/dev/null )
  [ -z "$stderr" ]
}
