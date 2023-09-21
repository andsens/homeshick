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

@test 'refresh a freshly cloned castle' {
  castle 'rc-files'

  $EXPECT_INSTALLED || skip 'expect not installed'
  open_bracket="\\u005b"
  close_bracket="\\u005d"
  esc="\\u001b$open_bracket"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" refresh rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     outdated${esc}0m rc-files\r
${esc}1;37m      refresh${esc}0m The castle rc-files is outdated.\r
${esc}1;36m        pull?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
      send "y\n"
      expect EOF
EOF
}

@test 'refresh a castle that was just pulled' {
  castle 'rc-files'
  homeshick pull rc-files
  homeshick -b refresh 7 rc-files
}

@test 'refresh a castle that was pulled 8 days ago' {
  castle 'rc-files'
  homeshick pull rc-files # creates the FETCH_HEAD file

  local fetch_head="$HOME/.homesick/repos/rc-files/.git/FETCH_HEAD"
  [ -f "$fetch_head" ]
  local timestamp
  system=$(uname -a)
  if [[ "$system" =~ "Linux" ]]; then
    timestamp=$(date -d "now - 8 days")
  else
    # assume BSD system
    timestamp=$(date -v -8d "+%Y-%m-%dT%H:%M:%S")
  fi
  touch -d "$timestamp" "$fetch_head"

  $EXPECT_INSTALLED || skip 'expect not installed'
  open_bracket="\\u005b"
  close_bracket="\\u005d"
  esc="\\u001b$open_bracket"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" refresh rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     outdated${esc}0m rc-files\r
${esc}1;37m      refresh${esc}0m The castle rc-files is outdated.\r
${esc}1;36m        pull?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
      send "y\n"
      expect EOF
EOF
}


@test 'refresh a castle and check that it is up to date' {
  castle 'rc-files'

  local current_head
  current_head=$(cd "$HOME/.homesick/repos/rc-files" && git rev-parse HEAD)
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD^1)

  $EXPECT_INSTALLED || skip 'expect not installed'
  open_bracket="\\u005b"
  close_bracket="\\u005d"
  esc="\\u001b$open_bracket"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" refresh rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     outdated${esc}0m rc-files\r
${esc}1;37m      refresh${esc}0m The castle rc-files is outdated.\r
${esc}1;36m        pull?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
      send "y\n"
      expect EOF
EOF
  local pulled_head
  pulled_head=$(cd "$HOME/.homesick/repos/rc-files" && git rev-parse HEAD)
  [ "$current_head" = "$pulled_head" ]
}

@test 'refresh a castle with spaces in name' {
  castle 'repo with spaces in name'

  $EXPECT_INSTALLED || skip 'expect not installed'
  open_bracket="\\u005b"
  close_bracket="\\u005d"
  esc="\\u001b$open_bracket"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" refresh "repo with spaces in name"
      expect -ex "${esc}1;36m     checking${esc}0m repo with spaces in name\r${esc}1;31m     outdated${esc}0m repo with spaces in name\r
${esc}1;37m      refresh${esc}0m The castle repo with spaces in name is outdated.\r
${esc}1;36m        pull?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
      send "y\n"
      expect EOF
EOF
}
