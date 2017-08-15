#!/usr/bin/env sh
# This script should be sourced in the context of your shell like so:
# source $HOME/.homeshick/repos/.homeshick/homeshick.sh
# Once the homeshick() function is defined, you can type
# "homeshick cd CASTLE" to enter a castle.

homeshick () {
	if [ "$1" = "cd" ] && [ -n "$2" ]; then
		# We want replicate cd behavior, so don't use cd ... ||
		# shellcheck disable=SC2164
		cd "$HOME/.homesick/repos/$2"
	else
		"${HOMESHICK_DIR:-$HOME/.homesick/repos/homeshick}/bin/homeshick" "$@"
	fi
}
