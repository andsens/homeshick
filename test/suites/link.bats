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

@test 'link file with crazy name' {
  castle 'repo with spaces in name'
  homeshick --batch link 'repo with spaces in name'
  stat "$HOME/.crazy
file␇☺"
  test -f "$HOME/.crazy
file␇☺"
}

@test 'link file with printf conversion chars' {
  castle 'repo with spaces in name'
  homeshick --batch link 'repo with spaces in name'
  stat "$HOME/%printf conver%sionchar%s %%"
  test -f "$HOME/%printf conver%sionchar%s %%"
}

@test 'do not fail when linking file with newline' {
 castle 'rc-files'
 test_filename="filename
newline"
 touch "$HOME/.homesick/repos/rc-files/home/$test_filename"
 commit_repo_state "$HOME/.homesick/repos/rc-files"
 homeshick --batch link rc-files
 [ -L "$HOME/filename
newline" ]
 is_symlink ".homesick/repos/rc-files/home/filename
newline" "$HOME/filename
newline"
}

@test 'link a file with spaces in its name' {
  castle 'repo with spaces in name'
  homeshick --batch link "repo with spaces in name"
  [ -f "$HOME/.file with spaces in name" ]
  [ -f "$HOME/.folder with spaces in name/another file with spaces in its name" ]
}

@test 'only link submodule files inside home/' {
  castle 'submodule-outside-home'
  # '!' inverts the return value
  ! homeshick --batch link submodule-outside-home 2>&1 | grep 'No such file or directory'
  # This is the best I can do for testing.
  # The failure does not cause any files to be created
  # Ostensibly homeshick should exit with $? != 0 when linking fails, but it doesn't
}

@test 'link files of nested submodules' {
  fixture 'nested-submodules'
  GIT_VERSION=$(get_git_version)
  run version_compare "$GIT_VERSION" 1.6.5
  [[ $status == 2 ]] && skip 'git version too low'

  homeshick --batch clone "$REPO_FIXTURES/nested-submodules"
  homeshick --batch link nested-submodules
  [ -f "$HOME/.subdir1/.subdir2/.info2" ]
}

@test "don't fail when linking uninitialized subrepos" {
  fixture 'nested-submodules'
  GIT_VERSION=$(get_git_version)
  run version_compare "$GIT_VERSION" 1.6.5
  [[ $status == 2 ]] && skip 'git version too low'

  git clone "$REPO_FIXTURES/nested-submodules" "$HOME/.homesick/repos/nested-submodules"
  [ -f "$HOME/.homesick/repos/nested-submodules/info" ]
  homeshick --batch link nested-submodules
  [ ! -f "$HOME/.homesick/repos/nested-submodules/home/.info" ]
  [ ! -f "$HOME/.info" ]
}

@test 'link submodule files' {
  fixture 'nested-submodules'
  GIT_VERSION=$(get_git_version)
  run version_compare "$GIT_VERSION" 1.6.5
  [[ $status == 2 ]] && skip 'git version too low'

  homeshick --batch clone "$REPO_FIXTURES/nested-submodules"
  homeshick --batch link nested-submodules
  [ -f "$HOME/.info" ]
  [ -f "$HOME/.subdir1/.info1" ]
}

@test 'link repo with no dirs in home/' {
  castle 'nodirs'
  homeshick --batch link nodirs
  [ -f "$HOME/.file1" ]
}

@test 'create file-less parent directories' {
  castle 'dotfiles'
  homeshick --batch link dotfiles
  [ -d "$HOME/.config/foo/bar" ]
}

@test 'symlink to a relative symlink' {
  castle 'symlinks'
  echo "test" > "$HOME/file_in_homedir"
  homeshick --batch link symlinks
  [ "$(cat "$HOME/link_to_homedir_file")" = 'test' ]
}

@test 'overwrite prompt skipped when linking and --batch is on' {
  castle 'rc-files'
  touch "$HOME/.bashrc"
  homeshick --batch link rc-files
  [ -f "$HOME/.bashrc" ]
  [ ! -L "$HOME/.bashrc" ]
}

@test 'overwrite file with link when the prompt is answered with yes' {
  $EXPECT_INSTALLED || skip 'expect not installed'

  castle 'rc-files'
  open_bracket="\\u005b"
  close_bracket="\\u005d"
  esc="\\u001b$open_bracket"
  touch "$HOME/.bashrc"
  cat <<EOF | expect -f -
      spawn "$HOMESHICK_DIR/bin/homeshick" link rc-files
      expect -ex "${esc}1;37m     conflict${esc}0m .bashrc exists\r
${esc}1;36m   overwrite?${esc}0m ${open_bracket}yN${close_bracket}" {} default {exit 1}
      send "y\n"
      expect EOF
EOF
  [ -L "$HOME/.bashrc" ]
}

@test "don't overwrite file or prompt for it when linking and --skip is on" {
  castle 'rc-files'
  touch "$HOME/.bashrc"
  homeshick --skip link rc-files
  [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]
}

@test 'existing symlinks are not relinked when running link' {
  castle 'module-files'
  homeshick --batch link module-files
  local inode_before
  inode_before=$(get_inode_no "$HOME/.my_module")
  homeshick --batch link module-files
  local inode_after
  inode_after=$(get_inode_no "$HOME/.my_module")
  [ "$inode_before" -eq "$inode_after" ]
}

@test 'traverse into the folder structure when linking' {
  castle 'dotfiles'
  mkdir -p "$HOME/.config/bar.dir"
  cat > "$HOME/.config/foo.conf" <<EOF
#I am just a regular foo.conf file
[foo]
A=True
EOF
  cat > "$HOME/.config/bar.dir/bar.conf" <<EOF
#I am just a regular bar.conf file
[bar]
A=True
EOF

  [ -f "$HOME/.config/foo.conf" ]
  #.config/foo.conf should be overwritten by a directory of the same name
  [ -d "$HOME/.config/bar.dir" ]
  #.config/bar.dir should be overwritten by a file of the same name
  homeshick --batch --force link dotfiles
  [ -d "$HOME/.config/foo.conf" ]
  [ -f "$HOME/.config/bar.dir" ]
}

@test 'treat symlinked directories in the castle like files when linking' {
  castle 'module-files'
  homeshick --batch link module-files
  [ -L "$HOME/.my_module" ]
}

@test '.git directories are not symlinked' {
  castle 'dotfiles'
  homeshick --batch link dotfiles
  [ ! -e "$HOME/.vim/.git" ]
}

@test 'link a castle with spaces in its name' {
  castle 'repo with spaces in name'
  homeshick --batch link repo\ with\ spaces\ in\ name
  [ -f "$HOME/.repowithspacesfile" ]
}

@test 'pass multiple castlenames to link' {
  castle 'rc-files'
  castle 'dotfiles'
  castle 'repo with spaces in name'
  homeshick --batch link rc-files dotfiles repo\ with\ spaces\ in\ name
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
  is_symlink ../.homesick/repos/dotfiles/home/.ssh/known_hosts "$HOME/.ssh/known_hosts"
  is_symlink ".homesick/repos/repo with spaces in name/home/.repowithspacesfile" "$HOME/.repowithspacesfile"
}

@test 'link all castles when no castle is specified' {
  castle 'rc-files'
  castle 'dotfiles'
  castle 'repo with spaces in name'
  homeshick --batch link
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
  is_symlink ../.homesick/repos/dotfiles/home/.ssh/known_hosts "$HOME/.ssh/known_hosts"
  is_symlink ".homesick/repos/repo with spaces in name/home/.repowithspacesfile" "$HOME/.repowithspacesfile"
}

@test 'files ignored by git should not be linked' {
  castle 'dotfiles'
  touch "$HOME/.homesick/repos/dotfiles/home/shouldBeIgnored.txt"
  cat > "$HOME/.homesick/repos/dotfiles/.gitignore" <<EOF
shouldBeIgnored.txt
EOF
  commit_repo_state "$HOME/.homesick/repos/dotfiles"
  homeshick --batch link dotfiles
  [ ! -L "$HOME/shouldBeIgnored.txt" ]
}

@test 'link file into directory that is a relative symlink' {
  castle 'dotfiles'
  mkdir -p "$HOME/two-levels/under-home"
  ln -s "two-levels/under-home" "$HOME/.ssh"
  homeshick --batch link
  is_symlink ../../.homesick/repos/dotfiles/home/.ssh/known_hosts "$HOME/two-levels/under-home/known_hosts"
  [ -f "$HOME/.ssh/known_hosts" ]
}

@test 'link file into directory that is an absolute symlink' {
  castle 'dotfiles'
  mkdir -p "$HOME/two-levels/under-home"
  ln -s "$HOME/two-levels/under-home" "$HOME/.config"
  homeshick --batch link
  is_symlink ../../.homesick/repos/dotfiles/home/.config/bar.dir "$HOME/two-levels/under-home/bar.dir"
}
