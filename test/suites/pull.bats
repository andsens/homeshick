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

@test 'pull skips castles with no upstream remote' {
  castle 'rc-files'
  castle 'dotfiles'
  # The dotfiles FETCH_HEAD should not exist after cloning
  [ ! -e "$HOME/.homesick/repos/dotfiles/.git/FETCH_HEAD" ]
  (cd "$HOME/.homesick/repos/rc-files" && git remote rm origin)
  run homeshick pull rc-files dotfiles
  [ $status -eq 0 ] # EX_SUCCESS
  # dotfiles FETCH_HEAD should exist if the castle was pulled
  [ -e "$HOME/.homesick/repos/dotfiles/.git/FETCH_HEAD" ]
}
