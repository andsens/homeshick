#!/usr/bin/env bash

refresh() {
  [[ ! $1 || ! $2 ]] && help_err refresh
  local threshhold=$1
  local castle=$2
  # repos is a global variable
  # shellcheck disable=SC2154
  local fetch_head="$repos/$castle/.git/FETCH_HEAD"
  pending 'checking' "$castle"
  castle_exists 'refresh' "$castle"

  if [[ -e $fetch_head ]]; then
    local last_mod
    last_mod=$(stat -c %Y "$fetch_head" 2> /dev/null || stat -f %m "$fetch_head")
    if [[ $((T_START-last_mod)) -gt $threshhold ]]; then
      fail "outdated"
      return "$EX_TH_EXCEEDED"
    else
      success "fresh"
      return "$EX_SUCCESS"
    fi
  else
    fail "outdated"
    return "$EX_TH_EXCEEDED"
  fi
}

pull_outdated() {
  local threshhold=$1; shift
  local outdated_castles=()
  while [[ $# -gt 0 ]]; do
    local castle=$1; shift
    local repo="$repos/$castle"
    if [[ ! -d $repo ]]; then
      # bogus argument, skip. User has already been warned by refresh()
      continue
    fi
    local fetch_head="$repo/.git/FETCH_HEAD"
    # When in interactive mode:
    # No matter if we are going to pull the castles or not
    # we reset the outdated ones by touching FETCH_HEAD
    if [[ -e $fetch_head ]]; then
      local last_mod
      last_mod=$(stat -c %Y "$fetch_head" 2> /dev/null || stat -f %m "$fetch_head")
      if [[ $((T_START-last_mod)) -gt $threshhold ]]; then
        outdated_castles+=("$castle")
        ! $BATCH && touch "$fetch_head"
      fi
    else
      outdated_castles+=("$castle")
      ! $BATCH && touch "$fetch_head"
    fi
  done
  ask_pull "${outdated_castles[@]}"
  return "$EX_SUCCESS"
}

ask_pull() {
  if [[ $# -gt 0 ]]; then
    if [[ $# == 1 ]]; then
      msg="The castle $1 is outdated."
    else
      OIFS=$IFS
      IFS=,
      msg="The castles $* are outdated."
      IFS=$OIFS
    fi
    if prompt_no 'refresh' "$msg" 'pull?' 0; then
      # shellcheck source=pull.sh disable=SC2154
      source "$homeshick/lib/commands/pull.sh"
      for castle in "$@"; do
        pull "$castle"
      done
    fi
  fi
  return "$EX_SUCCESS"
}
