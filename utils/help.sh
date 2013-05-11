#!/bin/bash
function help {
	if [[ $1 ]]; then
		extended_help $1
		exit $EX_SUCCESS
	fi
printf "homes${bldblu}h${txtdef}ick uses git in concert with symlinks to track your precious dotfiles.

 Usage: homeshick [options] TASK

 Tasks:
  homeshick clone URI..               # Clone URI as a castle for homeshick
  homeshick generate CASTLE..         # Generate a castle repo
  homeshick list                      # List cloned castles
  homeshick check [CASTLE..]          # Check a castle for updates
  homeshick refresh [DAYS] [CASTLE..] # Check if a castle needs refreshing
  homeshick pull [CASTLE..]           # Update a castle
  homeshick link [CASTLE..]           # Symlinks all dotfiles from a castle
  homeshick track CASTLE FILE..       # Add a file to a castle
  homeshick help [TASK]               # Show usage of a task

 Aliases:
  symlink # Alias to link
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
      printf "Clones URI as a castle for homeshick\n"
      printf "Usage:\n  homeshick clone URL.."
      ;;
		generate)
      printf "Generates a repo prepped for usage with homeshick\n"
      printf "Usage:\n  homeshick generate CASTLE.."
      ;;
		list)
      printf "Lists cloned castles\n"
      printf "Usage:\n  homeshick list"
      ;;
		check|updates)
      printf "Checks if a castle has been updated on the remote\n"
      printf "Usage:\n  homeshick $1 [CASTLE..]"
      ;;
    refresh)
      printf "Checks if a castle has not been pulled in DAYS days.\n"
      printf "The default is one week.\n"
      printf "Usage:\n  homeshick refresh [DAYS] [CASTLE..]"
      ;;
		pull)
      printf "Updates a castle. Also recurse into submodules.\n"
      printf "Usage:\n  homeshick pull [CASTLE..]"
      ;;
		link|symlink)
      printf "Symlinks all dotfiles from a castle\n"
      printf "Usage:\n  homeshick $1 [CASTLE..]"
      ;;
		track)
      printf "Adds a file to a castle.\n"
      printf "This moves the file into the castle and creates a symlink in its place.\n"
      printf "Usage:\n  homeshick track CASTLE FILE.."
      ;;
		help)
      printf "Shows usage of a task\n"
      printf "Usage:\n  homeshick help [TASK]"
      ;;
		*)    help  ;;
		esac
	printf "\n\n"
}
