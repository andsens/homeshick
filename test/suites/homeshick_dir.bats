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

@test 'bash with homeshick_dir override' {
  castle 'dotfiles'
  local result
  # shellcheck disable=SC2119
  result=$( HOMESHICK_DIR=$_TMPDIR/nowhere homeshick 2>&1 >/dev/null ) || true
  [[ "$result" =~ "/nowhere/" ]] || false
}

@test 'fish with homeshick_dir override' {
  [ "$(type -t fish)" = "file" ] || skip "fish not installed"
  cmd="source \"$HOMESHICK_DIR/homeshick.fish\"; set HOMESHICK_DIR \"$_TMPDIR/nowhere\"; homeshick"
  local result
  result=$( fish <<< "$cmd" 2>&1 >/dev/null ) || true
  [[ "$result" =~ "/nowhere/" ]] || false
}

@test 'csh with homeshick_dir override' {
  [ "$(type -t csh)" = "file" ] || skip "csh not installed"
  # "source" command expected to error, but csh must exit 0 or test will fail
  cmd="set HOMESHICK_DIR=/nowhere; source \"$HOMESHICK_DIR/homeshick.csh\"; exit 0"
  local result
  >&2 printf 'HOMESHICK_DIR=%s\n' "$HOMESHICK_DIR"
  result=$( csh <<< "$cmd" 2>&1 >/dev/null )
  [[ "$result" =~ "/nowhere/" ]] || false
}
