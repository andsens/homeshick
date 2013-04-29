#!/bin/bash

# Define some colors
txtdef="\e[0m"    # Revert to default
bldred="\e[1;31m" # Red - error
bldgrn="\e[1;32m" # Green - success
bldblu="\e[1;34m" # Blue - no action/ignored
bldcyn="\e[1;36m" # Cyan - pending action
bldwht="\e[1;37m" # White - info

function err {
	local exit_status=$1
	local reason="$2"
	shift 2
	if [[ $pending_status ]]; then
		fail
	fi
	status "$bldred" "error" "$reason" >&2
	for line in "$@"; do
		printf "$line\n" >&2
	done
	exit $exit_status
}

function status {
	if $TALK; then
		printf "$1%13s$txtdef %s\n" "$2" "$3"
	fi
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


# Singleline prompt that stays on the same line even if you press enter.
# Automatically colors the line according to the answer the user gives.
# Currently homeshick only has prompts with "no" as the default,
# so there's no reason to implement prompt_yes right now
function prompt_no {
	local status=$1
	local message=$2
	local prompt=$3
	local result=-1
	status "$bldwht" "$status" "$message"
	pending "$prompt" "[yN] "
	if ! $BATCH; then
		while true; do
			local answer=""
			local char=""
			while true; do
				read -s -n 1 char
				if [[ $char == "" ]]; then
					break
				fi
				printf "%c" $char
				answer="${answer}${char}"
			done
			case $answer in
				Y|y) result=0 ;;
				N|n) result=1 ;;
				"")  result=2 ;;
			esac
			[[ ! $result < 0 ]] && break
			for (( i=0; i<${#answer}; i++ )) ; do
				printf "\b"
			done
			printf "%${#answer}s\r"
			pending "$pending_status" "$pending_message"
		done
	else
		result=2
	fi
	if [[ $result == 0 ]]; then
		success
	else
		fail
	fi
	return $result
}
