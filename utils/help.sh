#!/bin/bash
function extend_help {
	case $1 in
		clone)    printf "Usage:\n  homesick clone URL"          ;;
		generate) printf "Usage:\n  homesick generate PATH"      ;;
		help)     printf "Usage:\n  homesick help [TASK]"        ;;
		list)     printf "Usage:\n  homesick list"               ;;
		updates)  printf "Usage:\n  homesick updates"            ;;
		pull)     printf "Usage:\n  homesick pull NAME"          ;;
		symlink)  printf "Usage:\n  homesick symlink NAME"       ;;
		track)    printf "Usage:\n  homesick track FILE CASTLE"  ;;
		*)    help  ;;
		esac
	printf "\n\n"
	cat <<EOM
 Runtime options:
   -q, [--quiet]    # Suppress status output
   -s, [--skip]     # Skip files that already exist
   -f, [--force]    # Overwrite files that already exist

EOM
}

function help {
cat <<EOM
 Usage: homesick [options] TASK

 Tasks:
  homesick clone URI          # Clone +uri+ as a castle for homeshick
  homesick generate PATH      # generate a homeshick-ready git repo at PATH
  homesick help [TASK]        # Describe available tasks or one specific task
  homesick list               # List cloned castles
  homesick updates            # Check all repositories for updates
  homesick pull NAME          # Update the specified castle
  homesick symlink NAME       # Symlinks all dotfiles from the specified castle
  homesick track FILE CASTLE  # add a file to a castle
EOM
}
