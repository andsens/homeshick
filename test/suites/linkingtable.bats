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

## This is the linking table we are trying to verify:
## "not directory" can be a regular file or a symlink to either a file or a directory
##        $HOME\repo    | not directory | directory ##
## ---------------------|---------------|---------- ##
## nonexistent          | link          | mkdir     ##
## symlink to repofile  | identical     | rm!&mkdir ##
## file                 | rm?&link      | rm?&mkdir ##
## directory            | rm?&link      | identical ##
## directory (symlink)  | rm?&link      | identical ##


## First row: nonexistent
## First column: not directory
@test 'link file to nonexistent' {
  castle 'rc-files'
  homeshick --batch link rc-files
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
}

@test 'link file symlink to nonexistent' {
  castle 'rc-files'
  homeshick --batch link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-file "$HOME/symlinked-file"
}

@test 'link dir symlink to nonexistent' {
  castle 'rc-files'
  homeshick --batch link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-directory "$HOME/symlinked-directory"
}

@test 'link dead symlink to nonexistent' {
  castle 'rc-files'
  homeshick --batch link rc-files
  is_symlink .homesick/repos/rc-files/home/dead-symlink "$HOME/dead-symlink"
}

## First row: nonexistent
## Second column: directory
@test 'link dir to nonexistent' {
  castle 'dotfiles'
  homeshick --batch link dotfiles
  [ ! -L "$HOME/.ssh" ]
  [ -d "$HOME/.ssh" ]
}


## Second row: symlink to repofile
## First column: not directory
@test 'link file to reposymlink' {
  castle 'rc-files'
  homeshick --batch link rc-files
  local inode_before
  inode_before=$(get_inode_no "$HOME/.bashrc")
  homeshick --batch --force link rc-files
  local inode_after
  inode_after=$(get_inode_no "$HOME/.bashrc")
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
  [ "$inode_before" -eq "$inode_after" ]
}

@test 'link file symlink to reposymlink' {
  castle 'rc-files'
  homeshick --batch link rc-files
  local inode_before
  inode_before=$(get_inode_no "$HOME/symlinked-file")
  homeshick --batch --force link rc-files
  local inode_after
  inode_after=$(get_inode_no "$HOME/symlinked-file")
  is_symlink .homesick/repos/rc-files/home/symlinked-file "$HOME/symlinked-file"
  [ "$inode_before" -eq "$inode_after" ]
}

@test 'link dir symlink to reposymlink' {
  castle 'rc-files'
  homeshick --batch link rc-files
  local inode_before
  inode_before=$(get_inode_no "$HOME/symlinked-directory")
  homeshick --batch --force link rc-files
  local inode_after
  inode_after=$(get_inode_no "$HOME/symlinked-directory")
  is_symlink .homesick/repos/rc-files/home/symlinked-directory "$HOME/symlinked-directory"
  [ "$inode_before" -eq "$inode_after" ]
}

@test 'link dead symlink to reposymlink' {
  castle 'rc-files'
  homeshick --batch link rc-files
  local inode_before
  inode_before=$(get_inode_no "$HOME/dead-symlink")
  homeshick --batch --force link rc-files
  local inode_after
  inode_after=$(get_inode_no "$HOME/dead-symlink")
  is_symlink .homesick/repos/rc-files/home/dead-symlink "$HOME/dead-symlink"
  [ "$inode_before" -eq "$inode_after" ]
}

## Second row: symlink to repofile
## Second column: directory
@test 'link legacy symlinks' {
  castle 'dotfiles'
  # Recreate the legacy scenario
  ln -s "$HOME/.homesick/repos/dotfiles/home/.ssh" "$HOME/.ssh"
  homeshick --batch --force link dotfiles
  # Without legacy handling if we were to run `file $HOME/.ssh/known_hosts` we would get
  # .ssh/known_hosts: symbolic link in a loop
  # The `test -e` is sufficient though
  [ -e "$HOME/.ssh/known_hosts" ]
}


## Third row: file
## First column: not directory
@test 'link file to file' {
  castle 'rc-files'
  touch "$HOME/.bashrc"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
}

@test 'link file symlink to file' {
  castle 'rc-files'
  touch "$HOME/symlinked-file"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-file "$HOME/symlinked-file"
}

@test 'link dir symlink to file' {
  castle 'rc-files'
  mkdir "$HOME/symlinked-directory"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-directory "$HOME/symlinked-directory"
}

@test 'link dead symlink to file' {
  castle 'rc-files'
  touch "$HOME/dead-symlink"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/dead-symlink "$HOME/dead-symlink"
}

## Third row: file
## Second column: directory
@test 'link dir to file' {
  castle 'dotfiles'
  touch "$HOME/.ssh"
  homeshick --batch --force link dotfiles
  [ -d "$HOME/.ssh" ]
  [ ! -L "$HOME/.ssh" ]
}


## Fourth row: directory
## First column: not directory
@test 'link file to dir' {
  castle 'rc-files'
  mkdir "$HOME/.bashrc"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
}

@test 'link file symlink to dir' {
  castle 'rc-files'
  mkdir "$HOME/symlinked-file"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-file "$HOME/symlinked-file"
}

@test 'link dir symlink to dir' {
  castle 'rc-files'
  mkdir "$HOME/symlinked-directory"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-directory "$HOME/symlinked-directory"
}

@test 'link dead symlink to dir' {
  castle 'rc-files'
  mkdir "$HOME/dead-symlink"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/dead-symlink "$HOME/dead-symlink"
}

## Fourth row: directory
## Second column: directory
@test 'link dir to dir' {
  castle 'dotfiles'
  mkdir "$HOME/.ssh"
  local inode_before
  inode_before=$(get_inode_no "$HOME/.ssh")
  homeshick --batch --force link dotfiles
  local inode_after
  inode_after=$(get_inode_no "$HOME/.ssh")
  [ "$inode_before" -eq "$inode_after" ]
  [ -d "$HOME/.ssh" ]
  [ ! -L "$HOME/.ssh" ]
}


## Fourth row: directory
## First column: not directory
@test 'link file to dir symlink' {
  castle 'rc-files'
  mkdir "$NOTHOME/symlink-target-dir"
  ln -s "$NOTHOME/symlink-target-dir" "$HOME/.bashrc"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/.bashrc "$HOME/.bashrc"
  rm -rf "$NOTHOME/symlink-target-dir"
}

@test 'link file symlink to dir symlink' {
  castle 'rc-files'
  mkdir "$NOTHOME/symlink-target-dir"
  ln -s "$NOTHOME/symlink-target-dir" "$HOME/symlinked-file"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-file "$HOME/symlinked-file"
  rm -rf "$NOTHOME/symlink-target-dir"
}

@test 'link dir symlink to dir symlink' {
  castle 'rc-files'
  mkdir "$NOTHOME/symlink-target-dir"
  ln -s "$NOTHOME/symlink-target-dir" "$HOME/symlinked-directory"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/symlinked-directory "$HOME/symlinked-directory"
  rm -rf "$NOTHOME/symlink-target-dir"
}

@test 'link dead symlink to dir symlink' {
  castle 'rc-files'
  mkdir "$NOTHOME/symlink-target-dir"
  ln -s "$NOTHOME/symlink-target-dir" "$HOME/dead-symlink"
  homeshick --batch --force link rc-files
  is_symlink .homesick/repos/rc-files/home/dead-symlink "$HOME/dead-symlink"
  rm -rf "$NOTHOME/symlink-target-dir"
}

## Fourth row: directory
## Second column: directory
@test 'link dir to dir symlink' {
  castle 'dotfiles'
  mkdir "$NOTHOME/symlink-target-dir"
  ln -s "$NOTHOME/symlink-target-dir" "$HOME/.ssh"
  local inode_before
  inode_before=$(get_inode_no "$HOME/.ssh")
  homeshick --batch --force link dotfiles
  local inode_after
  inode_after=$(get_inode_no "$HOME/.ssh")
  is_symlink "$NOTHOME/symlink-target-dir" "$HOME/.ssh"
  [ "$inode_before" -eq "$inode_after" ]
  [ -d "$HOME/.ssh" ]
  [ -L "$HOME/.ssh" ]
  rm -rf "$NOTHOME/symlink-target-dir"
}
