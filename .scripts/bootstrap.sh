#!/bin/bash

# ANSI escape codes for colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Define the GitHub repository for your dotfiles
DOTFILES_REPO="https://github.com/michaelvanstraten/dotfiles.git"

# Directory for storing backups
BACKUP_DIR="$HOME/.dotfiles-backup"

# Function to print colored messages
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# Check if the script is running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    print_message "${YELLOW}" "Skipping installation of Git because not on macOS."
else
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        print_message "${YELLOW}" "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        print_message "${YELLOW}" "Installing Git..."
        brew install git
    else
        print_message "${YELLOW}" "Git is already installed."
    fi
fi

# Clone the dotfiles repository
git clone --bare "$DOTFILES_REPO" "$HOME/.dotfiles"

# Define a function to work with dotfiles
function dotfiles {
    git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Attempt to checkout dotfiles
dotfiles checkout 2>&1 | while read -r file; do
    if echo "$file" | grep -q "already exists"; then
        print_message "${RED}" "Backing up pre-existing dotfiles."
        dotfiles checkout 2>&1 | awk '/\s+\./ {print $1}' | xargs -I{} mv {} "$BACKUP_DIR/{}"
        break
    fi
done

# Set status.showUntrackedFiles to no to ignore untracked files
dotfiles config status.showUntrackedFiles no

# Install Packages using Brewfile
BREWFILE="$HOME/.homebrew/Brewfile"
if [ -f "$BREWFILE" ]; then
    print_message "${YELLOW}" "Installing packages from Brewfile..."
    brew bundle --file "$BREWFILE"
else
    print_message "${YELLOW}" "Brewfile not found. No packages to install."
fi
