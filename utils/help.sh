#!/bin/bash
function help {
	if [[ $1 ]]; then
		extended_help $1
		exit $EX_SUCCESS
	fi
printf "home${bldblu}s${txtdef}hick uses git in concert with symlinks to track your precious dotfiles.
It is a bash stand-in for the original homesick by technicalpickles.

 Usage: homesick [options] TASK

 Tasks:
  homesick clone URI..               # Clone URI as a castle for homesick
  homesick generate PATH..           # Generate a castle repo
  homesick list                      # List cloned castles
  homesick check [CASTLE..]          # Check a castle for updates
  homesick refresh [DAYS] [CASTLE..] # Check if a castle needs refreshing
  homesick pull [CASTLE..]           # Update a castle
  homesick symlink [CASTLE..]        # Symlinks all dotfiles from a castle
  homesick track CASTLE FILE..       # Add a file to a castle
  homesick help [TASK]               # Show usage of a task

 Aliases:
  link    # Alias to symlink
  updates # Alias to check

 Runtime options:
   -q, [--quiet]    # Suppress status output
   -s, [--skip]     # Skip files that already exist
   -f, [--force]    # Overwrite files that already exist
   -b, [--batch]    # Batch-mode: Skip interactive prompts / Choose the default

 Note:
  To check, refresh, pull or symlink all your castles
  simply omit the CASTLE argument

"
}

function help_err {
	extended_help $1
	exit $EX_USAGE
}

function extended_help {
	case $1 in
		clone)
      printf "Clones URI as a castle for homesick\n"
      printf "Usage:\n  homesick clone URL.."
      ;;
		generate)
      printf "Generates a repo prepped for usage with homeshick\n"
      printf "Usage:\n  homesick generate PATH.."
      ;;
		list)
      printf "Lists cloned castles\n"
      printf "Usage:\n  homesick list"
      ;;
		check|updates)
      printf "Checks if a castle has been updated on the remote\n"
      printf "Usage:\n  homesick $1 [CASTLE..]"
      ;;
    refresh)
      printf "Checks if a castle has not been pulled in DAYS days.\n"
      printf "The default is one week.\n"
      printf "Usage:\n  homesick refresh [DAYS] [CASTLE..]"
      ;;
		pull)
      printf "Updates a castle. Also recurse into submodules.\n"
      printf "Usage:\n  homesick pull [CASTLE..]"
      ;;
		link|symlink)
      printf "Symlinks all dotfiles from a castle\n"
      printf "Usage:\n  homesick $1 [CASTLE..]"
      ;;
		track)
      printf "Adds a file to a castle.\n"
      printf "This moves the file into the castle and creates a symlink in its place.\n"
      printf "Usage:\n  homesick track CASTLE FILE.."
      ;;
		help)
      printf "Shows usage of a task\n"
      printf "Usage:\n  homesick help [TASK]"
      ;;
		*)    help  ;;
		esac
	printf "\n\n"
}
