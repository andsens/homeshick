#!/bin/bash

function setup_homeshick {
	rm -rf "$HOMESICK" "$HOMESHICK_BIN"
	local hs_repo=$HOMESICK/repos/homeshick
	mkdir -p $hs_repo
	ln -s $(readlink -e $SCRIPTDIR/../home) $hs_repo/home
	ln -s $(readlink -e $SCRIPTDIR/../utils) $hs_repo/utils
	ln -s $hs_repo/home/.homeshick $HOMESHICK_BIN
}
