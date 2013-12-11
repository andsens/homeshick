# This helper script should be sourced via an alias, e.g.
#
#   alias homeshick="source $HOME/.homesick/repos/homeshick/bin/homeshick.sh"
#
# Use portable syntax to accommodate as many Bourne-family shells as possible.
cat >&2 <<EOM
You are invoking homeshick by sourcing bin/homeshick.sh
This method of invocation is deprecated and will soon be removed.
Please consider adding \`source \$HOME/.homesick/repos/homeshick/homeshick.sh'
to your .bashrc or .zshrc instead, this will define a homeshick() function
that you can run instead.
(Read more here: https://github.com/andsens/homeshick/issues/57)
EOM
if [ "$1" = "cd" ] && [ -n "$2" ]; then
    if [ -d "$HOME/.homesick/repos/$2/home" ]; then
        cd "$HOME/.homesick/repos/$2/home"
    else
        cd "$HOME/.homesick/repos/$2"
    fi
else
    $HOME/.homesick/repos/homeshick/bin/homeshick "$@"
fi
