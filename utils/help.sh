#!/bin/bash
function extend_help {
	case $1 in
		clone)    printf "Usage:\n  $0 clone URL"          ;;
		generate) printf "Usage:\n  $0 generate PATH"      ;;
		help)     printf "Usage:\n  $0 help [TASK]"        ;;
		list)     printf "Usage:\n  $0 list"               ;;
		updates)  printf "Usage:\n  $0 updates"            ;;
		pull)     printf "Usage:\n  $0 pull NAME"          ;;
		symlink)  printf "Usage:\n  $0 symlink NAME"       ;;
		track)    printf "Usage:\n  $0 track FILE CASTLE"  ;;
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
 Usage: $0 [options] TASK

 Tasks:
  $0 clone URI          # Clone +uri+ as a castle for homeshick
  $0 generate PATH      # generate a homeshick-ready git repo at PATH
  $0 help [TASK]        # Describe available tasks or one specific task
  $0 list               # List cloned castles
  $0 updates            # Check all repositories for updates
  $0 pull NAME          # Update the specified castle
  $0 symlink NAME       # Symlinks all dotfiles from the specified castle
  $0 track FILE CASTLE  # add a file to a castle
EOM
}
