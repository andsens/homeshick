#!bash
#
###############################################################################
#
# Bash completion for homeshick (https://github.com/andsens/homeshick).
#
# To use, add this line (or equivalent) to your .bashrc:
#
#   source ~/.homesick/repos/homeshick/completions/homeshick-completion.bash
#
###############################################################################
#
# Copyright (C) 2013 Jeremy Lin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################

_homeshick_basename()
{
    echo "${1##*/}"
}

_homeshick_castles()
{
    local repos="$HOME/.homesick/repos"
    for repo in $(find $repos -mindepth 2 -maxdepth 2 -type d -name .git); do
        _homeshick_basename ${repo%/.git}
    done
}

_homeshick_complete_castles()
{
    COMPREPLY=($(compgen -W "$(_homeshick_castles)" -- "$1"))
}

_homeshick_complete()
{
    COMPREPLY=()

    local -r cmds="
        cd
        clone
        generate
        list
        check
        refresh
        pull
        link
        track
        help
        symlink
        updates
    "
    local -r short_opts="-q      -s     -f      -b"
    local -r long_opts="--quiet --skip --force --batch"

    # Scan through the command line and find the homeshick command
    # (if present), as well as its expected position.
    local cmd
    local cmd_index=1 # Expected index of the command token.
    local i
    for (( i = 1; i < ${#COMP_WORDS[@]}; i++ )); do
        local word="${COMP_WORDS[i]}"
        case "$word" in
            -*)
                ((cmd_index++))
                ;;
            *)
                cmd="$word"
                break
                ;;
        esac
    done

    local cur="${COMP_WORDS[COMP_CWORD]}"

    if (( $COMP_CWORD < $cmd_index )); then
        # Offer option completions.
        case "$cur" in
            --*)
                COMPREPLY=($(compgen -W "$long_opts" -- $cur))
                ;;
            -*)
                COMPREPLY=($(compgen -W "$short_opts" -- $cur))
                ;;
            *)
                COMPREPLY=() # We should never get here.
                ;;
        esac
    elif (( $COMP_CWORD == $cmd_index )); then
        # Offer command name completions.
        COMPREPLY=($(compgen -W "$cmds" -- $cur))
    else
        # Offer command argument completions.
        case "$cmd" in
            check | pull | link | symlink | updates)
                # Offer one or more castle name completions.
                _homeshick_complete_castles "$cur"
                ;;
            cd)
                # Offer exactly one castle name completion.
                if (( $COMP_CWORD == $cmd_index + 1 )); then
                    _homeshick_complete_castles "$cur"
                fi
                ;;
            refresh)
                # Skip completion of the DAYS argument, but offer castle name
                # completions after that.
                if (( $COMP_CWORD > $cmd_index + 1 )); then
                    _homeshick_complete_castles "$cur"
                fi
                ;;
            track)
                # Offer one castle name completion, then filename completions
                # after that.
                if (( $COMP_CWORD == $cmd_index + 1 )); then
                    _homeshick_complete_castles "$cur"
                else
                    COMPREPLY=($(compgen -f -- "$cur"))
                fi
                ;;
            help)
                # Offer exactly one command name completion.
                if (( $COMP_CWORD == $cmd_index + 1 )); then
                    COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
                fi
                ;;
            *)  # clone | generate | <unknown_command>
                # Skip completion of unknowable arguments.
                ;;
        esac
    fi
}

complete -F _homeshick_complete homeshick
