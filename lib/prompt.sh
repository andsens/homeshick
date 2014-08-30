#!/bin/bash

function ask_symlink {
	if [[ $# -gt 0 ]]; then
		if [[ $# == 1 ]]; then
			msg="The castle $1 has new files."
		else
			OIFS=$IFS
			IFS=,
			msg="The castles $* have new files."
			IFS=$OIFS
		fi
		prompt_no 'updates' "$msg" 'symlink?'
		if [[ $? = 0 ]]; then
			source $homeshick/lib/commands/link.sh
			for castle in $*; do
				symlink "$castle"
			done
		fi
	fi
	return $EX_SUCCESS
}


# Singleline prompt that stays on the same line even if you press enter.
# Automatically colors the line according to the answer the user gives.
# Currently homeshick only has prompts with "no" as the default,
# so there's no reason to implement prompt_yes right now
function prompt_no {
	local OTALK=$TALK
	# Disable the quiet flag while prompting in interactive mode
	if ! $BATCH; then
		TALK=true
	fi

	local status=$1
	local message=$2
	local prompt=$3
	local result=-1

	status "$bldwht" "$status" "$message"
	if ! $BATCH; then
		pending "$prompt" "[yN] "
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
			[[ $result -ge 0 ]] && break
			for (( i=0; i<${#answer}; i++ )) ; do
				printf "\b"
			done
			printf "%${#answer}s\r"
			pending "$pending_status" "$pending_message"
		done
	else
		pending "$prompt" "BATCH - No"
		result=2
	fi
	if [[ $result == 0 ]]; then
		success
	else
		fail
	fi
	TALK=$OTALK
	return $result
}
