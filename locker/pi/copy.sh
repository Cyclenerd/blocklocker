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

# bash_aliases
if cp "$MY_DIR/bash_aliases" "$HOME/.bash_aliases"; then
	echo "    $HOME/.bash_aliases"
else
	echo_warning "Failed to install '.bash_aliases'"
fi

# screenrc
if cp "$MY_DIR/screenrc" "$HOME/.screenrc"; then
	echo "    $HOME/.screenrc"
else
	echo_warning "Failed to install '.screenrc'"
fi

# SSH
if [ -f "$HOME/.ssh/id_rsa" ]; then
	echo "    SSH key already exists, will not generate new ones"
else
	if [ -d "$HOME/.ssh" ]; then
		echo "    '$HOME/.ssh' already exists"
	else
		mkdir "$HOME/.ssh"
	fi
	if command_exists ssh-keygen; then
		echo -e 'y\n'|ssh-keygen -q -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
		if [ "$?" -ne 0 ]; then
			echo_warning "Failed to generate SSH key"
		else
			chmod 700 "$HOME/.ssh"
			chmod 600 "$HOME/.ssh/id_rsa"
			echo "    $HOME/.ssh/id_rsa"
		fi
	else
		echo_warning "'ssh-keygen' is needed"
	fi
fi

if [ -f "$HOME/.ssh/config" ]; then
	echo "    '$HOME/.ssh/config' already exists"
else
	if cp "$MY_DIR/sshconfig" "$HOME/.ssh/config"; then
		chmod 600 "$HOME/.ssh/config"
		echo "    $HOME/.ssh/config"
	else
		echo_warning "Failed to install SSH config"
	fi
fi

echo "👍  Done. Note that some of these changes require a logout/restart to take effect."