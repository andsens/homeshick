#!/usr/bin/env bats

load ../helper

@test 'generate a castle' {
  homeshick --batch generate my_repo
  [ -d "$HOME/.homesick/repos/my_repo" ]
}

@test 'generate a castle with spaces in name' {
  homeshick --batch generate my\ repo
  [ -d "$HOME/.homesick/repos/my repo" ]
}

@test 'generate a castle with spaces in name with fish' {
  [ "$(type -t fish)" = "file" ] || skip "fish not installed"
  cmd="source \"$HOMESHICK_DIR/homeshick.fish\"; and homeshick --batch generate my\ repo"
  fish <<< "$cmd" 2>&1
  [ -d "$HOME/.homesick/repos/my repo" ]
}
