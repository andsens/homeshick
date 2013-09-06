#!/bin/bash

function storm {
	[[ -z "$1" ]] && help storm
	CASTLE="$HOME/.homesick/repos/$1"
	local castle=$1
	castle_exists storm $castle
	local repo="$repos/$castle"
	export PS1="(Castle:`basename \"$castle\"`)\n$PS1"
	cd $repo
	$SHELL
	return $EX_SUCCESS
}
