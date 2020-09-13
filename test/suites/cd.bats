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

@test 'cd to dotfiles castle' {
  castle 'dotfiles'
  local dotfiles_dir=$HOME/.homesick/repos/dotfiles
  local result
  result=$(homeshick cd dotfiles && pwd)
  [ "$dotfiles_dir" = "$result" ]
}

@test 'cd to dotfiles castle subdirectory' {
  castle 'dotfiles'
  local dotfiles_dir=$HOME/.homesick/repos/dotfiles/home/.config/foo.conf
  local result
  result=$(homeshick cd dotfiles/home/.config/foo.conf && pwd)
  [ "$dotfiles_dir" = "$result" ]
}

@test 'cd to my_module castle' {
  castle 'module-files'
  homeshick --batch clone "$REPO_FIXTURES/my_module"
  local my_module_dir=$HOME/.homesick/repos/my_module
  local result
  result=$(homeshick cd my_module && pwd)
  [ "$my_module_dir" = "$result" ]
}

@test 'cd to nonexistent castle' {
  local current_dir=$PWD
  local result
  result=$(homeshick cd non_existent 2>/dev/null; pwd)
  [ "$current_dir" = "$result" ]
}

@test "cd'ing to nonexistent castle exits with errcode 1" {
  run homeshick cd non_existent
  [ "$status" -eq 1 ]
}

@test 'cd to castle with spaces in its name' {
  castle 'repo with spaces in name'
  local spaces_repo_dir="$HOME/.homesick/repos/repo with spaces in name"
  local result
  result=$(homeshick cd repo\ with\ spaces\ in\ name && pwd)
  [ "$spaces_repo_dir" = "$result" ]
}

@test 'cd to castle in sh' {
  [ "$(type -t sh)" = "file" ] || skip "sh not installed"
  castle 'dotfiles'
  local dotfiles_dir=$HOME/.homesick/repos/dotfiles
  cmd=". \"$HOMESHICK_DIR/homeshick.sh\" && homeshick cd dotfiles && echo \$PWD"
  local result
  result=$( sh <<< "$cmd" )
  [ "$dotfiles_dir" = "$result" ]
}

@test 'cd to castle in dash' {
  [ "$(type -t dash)" = "file" ] || skip "dash not installed"
  castle 'dotfiles'
  local dotfiles_dir=$HOME/.homesick/repos/dotfiles
  cmd=". \"$HOMESHICK_DIR/homeshick.sh\" && homeshick cd dotfiles && echo \$PWD"
  local result
  result=$( dash <<< "$cmd" )
  [ "$dotfiles_dir" = "$result" ]
}

@test 'cd to castle in csh' {
  [ "$(type -t csh)" = "file" ] || skip "csh not installed"
  $EXPECT_INSTALLED || skip 'expect not installed'
  # in csh we can't alias a command and use that command on the same line
  # % do_something; do_something_else
  # is apparently different from
  # % do_something
  # % do_something_else
  castle 'dotfiles'
  local dotfiles_dir=$HOME/.homesick/repos/dotfiles
  cat <<EOF | expect -f -
      spawn csh
      send "alias homeshick source \"$HOMESHICK_DIR/homeshick.csh\"\n"
      send "homeshick cd dotfiles\n"
      send "pwd\n"
      expect "*$dotfiles_dir*" {} default {exit 1}
      send "exit\n"
      expect EOF
EOF
}

@test 'cd to castle in fish' {
  [ "$(type -t fish)" = "file" ] || skip "fish not installed"
  castle 'dotfiles'
  # fish $PWD has all symlinks resolved
  local dotfiles_dir
  dotfiles_dir=$(cd "$HOME/.homesick/repos/dotfiles" && pwd -P)
  cmd="source \"$HOMESHICK_DIR/homeshick.fish\"; and homeshick cd dotfiles; and pwd"
  local result
  result=$( fish <<< "$cmd" )
  [ "$dotfiles_dir" = "$result" ]
}
