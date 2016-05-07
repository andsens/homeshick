# This script should be sourced in the context of your shell like so:
# source $HOME/.homesick/repos/homeshick/homeshick.fish
# Once the homeshick() function is defined, you can type
# "homeshick cd CASTLE" to enter a castle.

function homeshick
	if test \( (count $argv) = 2 -a $argv[1] = "cd" \)
        	if set -q HOMESICK_DIR
			cd "$HOMESICK_DIR/repos/$argv[2]"
		else
			cd "$HOME/.homesick/repos/$argv[2]"
		end	
	else if set -q HOMESHICK_DIR 
		eval $HOMESHICK_DIR/bin/homeshick $argv
	else
		eval $HOMESICK_DIR/repos/homeshick/bin/homeshick $argv
	end
end
