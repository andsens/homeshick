#!/usr/bin/env bash
# shellcheck disable=SC2016
printf '\nsource "$HOMESHICK_DIR/homeshick.sh"' >> "$HOME/.bashrc"
cat > "$HOME/.bashrc" <<'EOF'
source "$HOMESHICK_DIR/homeshick.sh"
source "$HOMESHICK_DIR/completions/homeshick-completion.bash"
EOF
cat > "$HOME/.zshrc" <<'EOF'
source "$HOMESHICK_DIR/homeshick.sh"
fpath=($HOMESHICK_DIR/completions $fpath)
autoload -U compinit
compinit
EOF
printf '\nalias homeshick source "$HOMESHICK_DIR/homeshick.csh"' >> "$HOME/.cshrc"
mkdir -p "$HOME/.config/fish"
printf '\nsource "$HOMESHICK_DIR/homeshick.fish"' >> "$HOME/.config/fish/config.fish"
