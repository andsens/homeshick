#!/usr/bin/env sh
# This script should be sourced in the context of your shell like so:
# source $HOME/.homesick/repos/.homeshick/homeshick.sh
# Once the homeshick() function is defined, you can type
# "homeshick cd CASTLE" to enter a castle.

homeshick () {
  HOMESHICK_STATUS=0
  HOMESHICK_BIN="${HOMESHICK_DIR:-$HOME/.homesick/repos/homeshick}/bin/homeshick"
  if [ "$1" = "cd" ]; then
    HOMESHICK_REPO_TARGET="$("$HOMESHICK_BIN" "$@")"
    # We want replicate cd behavior, so don't use cd ... ||
    # shellcheck disable=SC2164
    case "$HOMESHICK_REPO_TARGET" in
      /*) cd "$HOMESHICK_REPO_TARGET"; HOMESHICK_STATUS=$?;;
      *) [ -n "$HOMESHICK_REPO_TARGET" ] && printf '%s\n' "$HOMESHICK_REPO_TARGET"; HOMESHICK_STATUS=64;;
    esac
  else
    "$HOMESHICK_BIN" "$@"
    HOMESHICK_STATUS=$?
  fi
  unset HOMESHICK_BIN HOMESHICK_REPO_TARGET
  return "$HOMESHICK_STATUS"
}
