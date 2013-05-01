#!/bin/bash -e

function setup_homeshick {
	teardown_homeshick
	local hs_repo=$HOMESICK/repos/homeshick
	mkdir -p $hs_repo
	ln -s $(readlink -e $SCRIPTDIR/../home) $hs_repo/home
	ln -s $(readlink -e $SCRIPTDIR/../utils) $hs_repo/utils
	ln -s $hs_repo/home/.homeshick $HOMESHICK_BIN
}

function teardown_homeshick {
	# Don't pull a bumblebee, always put your rm -rf params in quotes, even if they are variables
	rm -rf "$HOMESICK" "$HOMESHICK_BIN"
}
