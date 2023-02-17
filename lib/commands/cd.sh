#!/usr/bin/env bash

homeshick_cd() {
  [[ ! $1 ]] && help_err cd

  local castle=$1

  # repos is a global variable
  # shellcheck disable=SC2154
  local repo="$repos/$castle"
  local repopath

  if [[ -n "$2" ]] && [[ -d "$repo" ]]; then
    local dirname
    dirname=$(abs_path "$2")
    if [[ $dirname != $HOME/* ]] && [[ $dirname != "$HOME" ]]; then
      err "$EX_ERR" "The directory $dirname must be in your home directory."
    fi
    if [[ ! -d $dirname ]]; then
      err "$EX_ERR" "$dirname does not exist or is not a directory."
    fi
    home_exists 'cd' "$castle"

    local relpath
    if [[ $dirname = "$HOME" ]]; then
      relpath=""
    else
      relpath=${dirname#$HOME/}
    fi
    local relpath_in_repo="home/$relpath"
    repopath="$repo/$relpath_in_repo"
    if [[ ! -e $repopath ]]; then
      err "$EX_ERR" "$relpath is not being tracked in $castle."
    fi
  else
    repopath="$repo"
  fi

  printf '%s\n' "$repopath"
  return "$EX_SUCCESS"
}
