#!/usr/bin/env bash

if [[ ! -d "$(dirname "${BASH_SOURCE[0]}")/bats/lib/support" ]]; then
  printf -- "bats libraries are missing - run get_bats_libs.sh\n" >&2
  exit 1
fi

load ../bats/lib/support/load.bash
load ../bats/lib/assert/load.bash
load ../bats/lib/file/load.bash

setup_file() {
  check_expect
  remove_coreutils_from_path
  determine_homeshick_dir
}

determine_homeshick_dir() {
  HOMESHICK_DIR=$(cd "$BATS_TEST_DIRNAME/../.." && echo "$PWD")
  export HOMESHICK_DIR
}

create_test_dir() {
  _TMPDIR="$(temp_make --prefix 'homeshick-')"
  REPO_FIXTURES="$_TMPDIR/repos"
  HOME="$_TMPDIR/home"
  NOTHOME="$_TMPDIR/nothome"
  mkdir "$REPO_FIXTURES" "$HOME" "$NOTHOME"

  git config --global init.defaultBranch master
  git config --global protocol.file.allow always
}

delete_test_dir() {
  # For some reason temp_del gets stuck when run running `rm -r`, might be
  # the setup on my PC. Work around it by adding `-f`
  if [[ $_TMPDIR != *homeshick-* ]]; then
    printf -- "%s does not look like a homeshick testing tmp dir!\n" "$_TMPDIR" >&3
    exit 1
  fi
  rm -rf "$_TMPDIR"
}

check_expect() {
  # Check if expect is installed
  if type expect &>/dev/null; then
    export EXPECT_INSTALLED=true
  else
    export EXPECT_INSTALLED=false
  fi
}

remove_coreutils_from_path() {
  # Check if coreutils is in PATH
  system=$(uname -a)
  if [[ $system =~ "Darwin" && ! $system =~ "AppleTV" ]] && type brew &>/dev/null; then
    coreutils_path=$(brew --prefix coreutils 2>/dev/null)/libexec/gnubin
    if [[ -d $coreutils_path && $PATH == *$coreutils_path* ]] && \
       [[ -z $HOMESHICK_KEEP_PATH || $HOMESHICK_KEEP_PATH == false ]]; then
      export PATH=${PATH//$coreutils_path/''}
      export PATH=${PATH//'::'/':'} # Remove any left over colons
    fi
  fi
}

fixture() {
  local name=$1
  if [[ ! -e "$REPO_FIXTURES/$name" ]]; then
    # shellcheck disable=SC1090
    source "$HOMESHICK_DIR/test/fixtures/$name.sh"
  fi
}

castle() {
  local fixture_name=$1
  fixture "$fixture_name"
  homeshick --batch clone "$REPO_FIXTURES/$fixture_name" > /dev/null
}

is_symlink() {
  expected=$1
  path=$2
  target=$(readlink "$path")
  [ "$expected" = "$target" ]
}

get_inode_no() {
  stat -c %i "$1" 2>/dev/null || stat -f %i "$1"
}

# Snatched from http://stackoverflow.com/questions/4023830/bash-how-compare-two-strings-in-version-format
version_compare() {
  if [[ $1 == "$2" ]]; then
    return 0
  fi
  local IFS=.
  # shellcheck disable=SC2206
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

get_git_version() {
  if [[ -z $GIT_VERSION ]]; then
    read -r _ _ GIT_VERSION _ < <(command git --version)
    if [[ ! $GIT_VERSION =~ ([0-9]+)(\.[0-9]+){0,3} ]]; then
      skip 'could not detect git version'
    fi
  fi
  printf "%s" "$GIT_VERSION"
}

commit_repo_state() {
  local repo=$1
  (
    # Let cd just fail
    # shellcheck disable=SC2164
    cd "$repo"
    git config user.name "Homeshick user"
    git config user.email "homeshick@example.com"
    git add -A
    git commit -m "Commiting Repo State from test helper.sh."
  )
}
