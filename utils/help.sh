#!/bin/bash
function help {
	if [ ! -z "$1" ]; then
		extended_help $1
		exit 0
	fi
printf "hom${bldblu}s${txtdef}hick uses git in concert with symlinks to track your precious dotfiles.
It is a bash stand-in for the original homesick by technicalpickles.

 Usage: homesick [options] TASK

 Tasks:
  homesick clone [URI..]         # Clone URI as a castle for homeshick
  homesick generate [PATH..]     # Generate a homeshick-ready git repo at PATH
  homesick list                  # List cloned castles
  homesick check [CASTLE..]      # Check a castle for updates
  homesick pull [CASTLE..]       # Update a castle
  homesick symlink [CASTLE..]    # Symlinks all dotfiles from a castle
  homesick track CASTLE [FILE..] # Add a file to a castle
  homesick help [TASK]           # Show usage of a task
 
 Runtime options:
   -q, [--quiet]    # Suppress status output
   -s, [--skip]     # Skip files that already exist
   -f, [--force]    # Overwrite files that already exist
 
 Note:
  To check, pull or symlink all your castles, simply omit the CASTLE argument
  
"
}

function help_err {
	extended_help $1
	[ -z "$2" ] && 2=1
	exit $2
}

function extended_help {
	case $1 in
		clone)    printf "Usage:\n  homesick clone [URL..]"         ;;
		generate) printf "Usage:\n  homesick generate [PATH..]"     ;;
		list)     printf "Usage:\n  homesick list"                  ;;
		check)    printf "Usage:\n  homesick check [CASTLE..]"      ;;
		pull)     printf "Usage:\n  homesick pull [CASTLE..]"       ;;
		symlink)  printf "Usage:\n  homesick symlink [CASTLE..]"    ;;
		track)    printf "Usage:\n  homesick track CASTLE [FILE..]" ;;
		help)     printf "Usage:\n  homesick help [TASK]"           ;;
		*)    help  ;;
		esac
	printf "\n\n"
}
