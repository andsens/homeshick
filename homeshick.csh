# This helper script should be sourced via an alias, e.g.
#
#   alias homeshick "source $HOME/.homesick/repos/homeshick/homeshick.csh"
#
if ( "$1" == "cd" && "x$2" != "x" ) then
    if ( -d "$HOME/.homesick/repos/$2/home" ) then
        cd "$HOME/.homesick/repos/$2/home"
    else
        cd "$HOME/.homesick/repos/$2"
    endif
else
    if ( $?HOMESHICK_DIR ) then
        $HOMESHICK_DIR/bin/homeshick $*
    else
        $HOME/.homesick/repos/homeshick/bin/homeshick $*
    endif
endif
