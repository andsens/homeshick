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

add_new_file_to_castle() {
  cd "$HOME/.homesick/repos/rc-files" || return $?
  touch homeshick_new_file_bats_test
}

add_empty_folder_to_castle() {
  cd "$HOME/.homesick/repos/rc-files" || return $?
  mkdir homeshick_new_folder_bats_test
}

modify_file_in_castle() {
  cd "$HOME/.homesick/repos/rc-files" || return $?
  echo modify >> "$(find home -type f | head -1)"
}

delete_file_in_castle() {
  cd "$HOME/.homesick/repos/rc-files" || return $?
  rm "$(find home -type f | head -1)"
}

add_commit_to_castle() {
  cd "$HOME/.homesick/repos/rc-files" || return $?
  git config user.name "Homeshick user"
  git config user.email "homeshick@example.com"

  cat >> home/.bashrc <<EOF
#!/usr/bin/env bash
PS1='\[33[01;32m\]\u@\h\[33[00m\]:\[33[01;34m\]\w\'
homeshick --batch refresh
EOF
  git add home/.bashrc
  git commit -m 'Added homeshick refresh check to .bashrc'
}

@test 'check an up to date castle' {
  castle 'rc-files'
  homeshick check rc-files

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;32m   up to date${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check an up to date castle with spaces in castle name' {
  castle 'repo with spaces in name'
  homeshick check 'repo with spaces in name'

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check "repo with spaces in name"
      expect -ex "${esc}1;36m     checking${esc}0m repo with spaces in name\r${esc}1;32m   up to date${esc}0m repo with spaces in name\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is behind upstream' {
  castle 'rc-files'
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD^1)
  run homeshick check rc-files
  [ $status -eq 86 ] # EX_BEHIND

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is behind upstream with a new file' {
  castle 'rc-files'
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD^ && add_new_file_to_castle)
  run homeshick check rc-files
  [ $status -eq 86 ] # EX_BEHIND

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is behind upstream with a modified file' {
  castle 'rc-files'
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD^1 && modify_file_in_castle)
  run homeshick check rc-files
  [ $status -eq 86 ] # EX_BEHIND

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is behind upstream with a deleted file' {
  castle 'rc-files'
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD^1 && delete_file_in_castle)
  run homeshick check rc-files
  [ $status -eq 86 ] # EX_BEHIND

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m       behind${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream' {
  castle 'rc-files'
  (add_commit_to_castle)
  run homeshick check rc-files
  [ $status -eq 85 ] # EX_AHEAD

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream with a new file' {
  castle 'rc-files'
  (add_commit_to_castle && add_new_file_to_castle)
  run homeshick check rc-files
  [ $status -eq 85 ] # EX_AHEAD

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream with a modified file' {
  castle 'rc-files'
  (add_commit_to_castle; modify_file_in_castle)
  run homeshick check rc-files
  [ $status -eq 85 ] # EX_AHEAD

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle that is ahead of upstream with a deleted file' {
  castle 'rc-files'
  (add_commit_to_castle && delete_file_in_castle)
  run homeshick check rc-files
  [ $status -eq 85 ] # EX_AHEAD

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m        ahead${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}


@test 'check a castle with a new file' {
  castle 'rc-files'
  (add_new_file_to_castle)
  run homeshick check rc-files
  [ $status -eq 88 ] # EX_MODIFIED

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     modified${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle with a modified file' {
  castle 'rc-files'
  (modify_file_in_castle)
  run homeshick check rc-files
  [ $status -eq 88 ] # EX_MODIFIED

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     modified${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle with a deleted file' {
  castle 'rc-files'
  (delete_file_in_castle)
  run homeshick check rc-files
  [ $status -eq 88 ] # EX_MODIFIED

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     modified${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle with a new empty folder' {
  castle 'rc-files'
  (add_empty_folder_to_castle)
  homeshick check rc-files

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;32m   up to date${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}

@test 'check a castle with a new folder and file in it' {
  castle 'rc-files'
  (
    add_empty_folder_to_castle && \
    cd "$HOME/.homesick/repos/rc-files" && \
    touch homeshick_new_folder_bats_test/some_file
  )
  run homeshick check rc-files
  [ $status -eq 88 ] # EX_MODIFIED

  $EXPECT_INSTALLED || skip 'expect not installed'
  esc="\\u001b\\u005b"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" check rc-files
      expect -ex "${esc}1;36m     checking${esc}0m rc-files\r${esc}1;31m     modified${esc}0m rc-files\r\n" {} default {exit 1}
EOF
}
