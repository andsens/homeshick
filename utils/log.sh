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
	if [[ $TALK = true && ! -z "$pending_status" ]]; then
		printf "\r$bldred%13s$txtdef %s\n" "$pending_status" "$pending_message"
	fi
	for line in "$@"; do
		printf "$line\n" >&2
	done
	exit 1
}

function status {
	if $TALK; then
		printf "$1%13s$txtdef %s\n" "$2" "$3"
	fi
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

function fail {
	if $TALK; then
		if [ "$1" ]; then
			pending_status=$1
		fi
		printf "\r$bldred%13s$txtdef %s\n" "$pending_status" "$pending_message"
	fi
}

function ignore {
	if $TALK; then
		if [ "$1" ]; then
			pending_status=$1
		fi
		printf "\r$bldblu%13s$txtdef %s\n" "$pending_status" "$pending_message"
	fi
}

function success {
	if $TALK; then
		if [ "$1" ]; then
			pending_status=$1
		fi
		printf "\r$bldgrn%13s$txtdef %s\n" "$pending_status" "$pending_message"
	fi
}

