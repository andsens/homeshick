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

@test 'check non-existent and existent castle' {
  castle 'rc-files'
  run homeshick check non-existent rc-files
  [ $status -eq 1 ] # EX_ERR
}

@test 'clone non-existent and existent castle' {
  fixture 'rc-files'
  run homeshick --batch clone "$REPO_FIXTURES/non-existent" "$REPO_FIXTURES/rc-files"
  [ $status -eq 70 ] # EX_SOFTWARE
  [ ! -d "$HOME/.homesick/repos/rc-files" ] # Should not exist, clone must fail early
}

@test 'generate castles with and without naming conflict' {
  castle 'rc-files'
  run homeshick generate rc-files nonexistent
  [ $status -eq 1 ] # EX_ERR
  [ ! -d "$HOME/.homesick/repos/nonexistent" ] # Should not exist, generate must fail early
}

@test 'link non-existent and existent castle' {
  castle 'rc-files'
  run homeshick link --batch rc-files nonexistent
  [ $status -eq 1 ] # EX_ERR
}

@test 'pull non-existent and existent castle' {
  castle 'rc-files'
  local current_head
  current_head=$(cd "$HOME/.homesick/repos/rc-files" && git rev-parse HEAD)
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD^1)
  run homeshick pull --batch non-existent rc-files
  [ $status -eq 1 ] # EX_ERR
  local pulled_head
  pulled_head=$(cd "$HOME/.homesick/repos/rc-files" && git rev-parse HEAD)
  [ "$current_head" = "$pulled_head" ]
}

@test 'refresh non-existent and existent castle' {
  castle 'rc-files'
  homeshick pull rc-files
  run homeshick refresh --batch 7 non-existent rc-files
  [ $status -eq 1 ] # EX_ERR
}

@test 'track non-existent and existent file in castle' {
  castle 'rc-files'
  touch "$HOME/.newfiletotrack"
  run homeshick track rc-files "$HOME/.newfiletotrack" "$HOME/.nonexistent"
  [ $status -eq 1 ] # EX_ERR
  [ -f "$HOME/.homesick/repos/rc-files/home/.newfiletotrack" ]
}

@test 'track existent and non-existent file in castle' {
  castle 'rc-files'
  touch "$HOME/.newfiletotrack"
  run homeshick track rc-files non-existent .newfiletotrack
  [ $status -eq 1 ] # EX_ERR
  [ ! -f "$HOME/.homesick/repos/rc-files/home/.newfiletotrack" ]
}
