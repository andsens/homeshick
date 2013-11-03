# This script should be sourced in the context of your shell like so:
# source $HOME/.homeshick/repos/.homeshick/homeshick.csh
# Once the homeshick() function is defined, you can type
# "homeshick cd CASTLE" to enter a castle.

homeshick() {
	if ( "$1" == "cd" && "x$2" != "x" ) then
		cd $HOME/.homesick/repos/$2
	else
		$HOME/.homesick/repos/homeshick/bin/homeshick $*
	endif
}
