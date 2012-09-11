#!/bin/bash

# Define some colors
txtdef="\e[0m"    # Revert to default
bldred="\e[1;31m" # Red - error
bldgrn="\e[1;32m" # Green - success
bldblu="\e[1;34m" # Blue - no action/ignored
bldcyn="\e[1;36m" # Cyan - pending action

function err {
	die "       $bldred error$txtdef $1"
}

function die {
	if [[ -z "$B_QUIET" && ! -z $pending_status ]]; then
		printf "\r$bldred%13s$txtdef %s\n" "$pending_status" "$pending_message"
	fi
	for line in "$@"; do
		printf "$line\n" >&2
	done
	exit 1
}

pending_status=''
pending_message=''
function pending {
	pending_status="$1"
	pending_message="$2"
	if [ -z "$B_QUIET" ]; then
		printf "$bldcyn%13s$txtdef %s" "$pending_status" "$pending_message"
	fi
}
function success {
	if [ -z "$B_QUIET" ]; then
		printf "\r$bldgrn%13s$txtdef %s\n" "$pending_status" "$pending_message"
	fi
}

function status {
	if [ -z "$B_QUIET" ]; then
		printf "$1%13s$txtdef %s\n" "$2" "$3"
	fi
}
