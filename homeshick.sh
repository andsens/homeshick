# This script should be sourced in the context of your shell like so:
# source homeshick.sh
# Once the homeshick() function is defined, you can type
# "homeshick cd CASTLE" to enter a castle.

__DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
eval "function homeshick() {
	if [ \"\$1\" = \"cd\" ] && [ -n \"\$2\" ]; then
		cd \"\$HOME/.homesick/repos/\$2\"
	else
		HOMESHICK_DIR=\"$__DIR\" \"$__DIR/bin/homeshick\" \"\$@\"
	fi
}"
unset __DIR

