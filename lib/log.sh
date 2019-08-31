#!/bin/bash

# Define some colors
txtdef="\e[0m"    # Revert to default
bldred="\e[1;31m" # Red - error
bldgrn="\e[1;32m" # Green - success
bldylw="\e[1;33m" # Yellow - warning
bldblu="\e[1;34m" # Blue - no action/ignored
bldcyn="\e[1;36m" # Cyan - pending action
bldwht="\e[1;37m" # White - info

function err {
	local exit_status=$1
	local reason="$2"
	shift 2
	if [[ $pending_status ]]; then
		# no args for fail
		# shellcheck disable=SC2119
		fail
	fi
	status "$bldred" "error" "$reason" >&2
	if [[ $# -gt 0 ]]; then
		printf "%s\n" "$@" >&2
	fi
	exit "$exit_status"
}

function help_err {
	# shellcheck source=lib/commands/help.sh disable=SC2154
	source "$homeshick/lib/commands/help.sh"
	extended_help "$1"
	exit "$EX_USAGE"
}

function status {
	if $TALK; then
		printf "$1%13s$txtdef %s\n" "$2" "$3"
	fi
}

function warn {
	status "$bldylw" "$1" "$2"
}

function info {
	status "$bldwht" "$1" "$2"
}

pending_status=''
pending_message=''
function pending {
	pending_status="$1"
	pending_message="$2"
	if $TALK; then
		printf "$bldcyn%13s$txtdef %s" "$pending_status" "$pending_message"
	fi
}

# fail is used globally
# shellcheck disable=SC2120
function fail {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldred" "$pending_status" "$pending_message"
	unset pending_status pending_message
}

function ignore {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldblu" "$pending_status" "$pending_message"
	unset pending_status pending_message
}

function success {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldgrn" "$pending_status" "$pending_message"
	unset pending_status pending_message
}
