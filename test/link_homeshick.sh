#!/bin/bash

function setup_homeshick {
	local hs_repo=$HOMESICK/repos/homeshick
	mkdir -p $hs_repo
	ln -s $(cd $SCRIPTDIR/../bin; printf "$(pwd)") $hs_repo/bin
	ln -s $(cd $SCRIPTDIR/../utils; printf "$(pwd)") $hs_repo/utils
}
