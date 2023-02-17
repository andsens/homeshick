# This script should be sourced in the context of your shell like so:
# source $HOME/.homesick/repos/homeshick/homeshick.fish
# Alternatively, it can be installed into one of the directories
# that fish uses to autoload functions (e.g ~/.config/fish/functions)
# Once the homeshick() function is defined, you can type
# "homeshick cd CASTLE" to enter a castle.

function homeshick
  if set -q HOMESHICK_DIR
    set -f homeshick_bin $HOMESHICK_DIR/bin/homeshick
  else if set homeshick (type -P homeshick 2> /dev/null)
    set -f homeshick_bin $homeshick 
  else
    set -f homeshick_bin $HOME/.homesick/repos/homeshick/bin/homeshick
  end
  if test \( "$argv[1]" = "cd" \)
    set -l homeshick_target_dir "$(eval $homeshick_bin (string escape -- $argv))"
    if string match -q "/*" "$homeshick_target_dir"
      cd "$homeshick_target_dir"
    else
      test -n "$homeshick_target_dir"; and printf '%s\n' "$homeshick_target_dir"
      return 64
    end
  else
    eval $homeshick_bin (string escape -- $argv)
  end
end
