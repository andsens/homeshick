#!/usr/bin/env bash
# This script is meant to be used in conjunction with
# `git submodule foreach'.
# It runs outputs all files tracked by a submodule.
# The paths are outputted relative to $root
root="$1"
toplevel="$2"
path="$3"
# toplevel/path relative to root
repo=${toplevel/#$root/}/$path
# If we are at root, remove the slash in front
repo=${repo/#\//}
# We are only interested in submodules under home/
if [[ $repo =~ ^home ]]; then
	# just let cd fail if the path does not exist
	# shellcheck disable=2164
	cd "$toplevel/$path"
	# List the files and prefix every line
	# with the relative repo path
	git ls-files | sed "s#^#${repo//#/\\#}/#"
fi
