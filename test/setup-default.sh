#!/usr/bin/env bash
printf '\nsource "$HOME/.homesick/repos/homeshick/homeshick.sh"' >> $HOME/.bashrc
cat > $HOME/.bashrc <<EOF
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "\$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
EOF
cat > $HOME/.zshrc <<EOF
source "\$HOME/.homesick/repos/homeshick/homeshick.sh"
fpath=(\$HOME/.homesick/repos/homeshick/completions \$fpath)
autoload -U compinit
compinit
EOF
printf '\nalias homeshick source "$HOME/.homesick/repos/homeshick/bin/homeshick.csh"' >> $HOME/.cshrc
mkdir -p $HOME/.config/fish
printf '\nsource "$HOME/.homesick/repos/homeshick/homeshick.fish"' >> "$HOME/.config/fish/config.fish"
