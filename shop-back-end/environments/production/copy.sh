#!/usr/bin/env bash

# Bash Script to automate post-installation steps. Helps to 
#  install dotfiles and
#  perform user-defined configurations.

################################################################################
# Helpers
################################################################################

# exit_with_message() outputs and logs a message before exiting the script.
function exit_with_message() {
	echo
	echo "☠  FAILURE: $1"
	echo
	exit 1
}

# echo_warning() outputs a message with warning icon.
function echo_warning() {
	echo "    ⚠️  $1, will attempt to continue..."
}

################################################################################
# MAIN
################################################################################

if [ -d "$HOME" ]; then
	echo "🏠  $HOME"
else
	exit_with_message "$HOME does not exist"
fi

MY_DIR=$( dirname "${BASH_SOURCE[0]}" )

# Backup
if [ -f "$HOME/.bashrc" ]; then
	cp "$HOME/.bashrc" "$HOME/.bashrc.ORIG"
fi

# .bashrc
BASHRC="$HOME/.bashrc"
echo "" >> "$BASHRC"
if cat "$MY_DIR/bashrc" >> "$BASHRC"; then
	echo "    $BASHRC"
	echo "" >> "$BASHRC"
else
	echo_warning "Failed to install '.bashrc'"
fi

# screenrc
if cp "$MY_DIR/screenrc" "$HOME/.screenrc"; then
	echo "    $HOME/.screenrc"
else
	echo_warning "Failed to install '.screenrc'"
fi

# convert.sh
if cp "$MY_DIR/convert.sh" "$HOME/convert.sh"; then
	echo "    $HOME/convert.sh"
else
	echo_warning "Failed to install 'convert.sh'"
fi

# reorg.sh
if cp "$MY_DIR/reorg.sh" "$HOME/reorg.sh"; then
	echo "    $HOME/reorg.sh"
else
	echo_warning "Failed to install 'reorg.sh'"
fi

echo "👍  Done. Note that some of these changes require a logout/restart to take effect."