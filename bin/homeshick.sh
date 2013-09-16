# This helper script should be sourced via an alias, e.g.
#
#   alias homeshick="source $HOME/.homesick/repos/homeshick/bin/homeshick.sh"
#
# Use portable syntax to accommodate as many Bourne-family shells as possible.
if [ "$1" = "cd" ] && [ -n "$2" ]; then
    if [ -d $HOME/.homesick/repos/$2/home ]; then
        cd $HOME/.homesick/repos/$2/home
    else
        cd $HOME/.homesick/repos/$2
    fi
else
    $HOME/.homesick/repos/homeshick/bin/homeshick "$@"
fi
