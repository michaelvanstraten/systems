#!/usr/bin/env sh

# Set the path to the directory containing SSH keys
KEYS_DIR="$HOME/.ssh/keys"

# Ensure the keys directory exists
mkdir -p "$KEYS_DIR"

# Set permissions for the .ssh directory
chmod 700 "$HOME/.ssh"

# Set permissions for the keys directory
chmod 700 "$KEYS_DIR"

# Set permissions for existing keys
chmod 600 "$KEYS_DIR"/*

# Set immutable attribute to prevent deletion of keys and config on Linux
if [[ "$(uname -s)" == "Linux" ]]; then
	chattr +i "$KEYS_DIR"
fi

# Set restricted flag to prevent deletion of keys and config on macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
	chflags uchg "$KEYS_DIR"
fi

echo "SSH key permissions and configuration locked down successfully."
