# This helper script should be sourced via an alias, e.g.
#
#   alias homeshick "source $HOME/.homesick/repos/homeshick/homeshick.csh"
#

set HOMESHICK_STATUS=0
if ( $?HOMESHICK_DIR ) then
    set HOMESHICK_BIN=$HOMESHICK_DIR/bin/homeshick
else
    set HOMESHICK_BIN=$HOME/.homesick/repos/homeshick/bin/homeshick
endif
if ( "$1" == "cd" ) then
    set HOMESHICK_REPO_TARGET="`$HOMESHICK_BIN $*`"
    if ( "$HOMESHICK_REPO_TARGET" =~ /* ) then
        cd "$HOMESHICK_REPO_TARGET"
        set HOMESHICK_STATUS=$status
    else
        if ("$HOMESHICK_REPO_TARGET" != "") then
            printf '%s\n' $HOMESHICK_REPO_TARGET:q
        endif
        set HOMESHICK_STATUS=64
    endif
    unset HOMESHICK_REPO_TARGET
else
    $HOMESHICK_BIN $*
    set HOMESHICK_STATUS=$status
endif
unset HOMESHICK_BIN
set status=$HOMESHICK_STATUS
