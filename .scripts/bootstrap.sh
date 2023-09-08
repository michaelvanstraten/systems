#!/bin/bash

# ANSI escape codes for colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Configuration options
DOTFILES_REPO="https://github.com/michaelvanstraten/dotfiles.git"
BREWFILE="$HOME/.homebrew/Brewfile"
BACKUP_DIR="$HOME/.dotfiles-backup"
LOG_FILE="$HOME/.dotfiles-install.log"

# Function to print colored messages
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# Function to check if a command is available
command_exists() {
    command -v "$1" &> /dev/null
}

# Check for dependencies
if ! command_exists "curl" || ! command_exists "awk"; then
    print_message "${RED}" "Error: Required dependencies (curl and awk) not found. Please install them manually and rerun the script."
    exit 1
fi

# Function to install Homebrew on macOS
install_homebrew() {
    print_message "${YELLOW}" "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Function to install Git if not already installed
install_git() {
    print_message "${YELLOW}" "Installing Git..."
    if [[ "$(uname -s)" == "Darwin" ]]; then
        brew install git
    else
        print_message "${RED}" "Error: Git is not installed. Please install Git manually and rerun the script."
        exit 1
    fi
}

# Check if Homebrew is installed (macOS only)
if [[ "$(uname -s)" == "Darwin" ]]; then
    if ! command_exists "brew"; then
        install_homebrew
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Check if Git is installed
if ! command_exists "git"; then
    install_git
else
    print_message "${YELLOW}" "Git is already installed."
fi

# Clone the dotfiles repository
git clone --bare "$DOTFILES_REPO" "$HOME/.dotfiles" &>> "$LOG_FILE"

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

# Install Packages using Brewfile (macOS only)
if [[ "$(uname -s)" == "Darwin" ]] && [ -f "$BREWFILE" ]; then
    print_message "${YELLOW}" "Installing packages from Brewfile..."
    brew bundle --file "$BREWFILE" &>> "$LOG_FILE"
elif [[ "$(uname -s)" == "Darwin" ]]; then
    print_message "${RED}" "Brewfile not found. No packages to install."
fi

print_message "${GREEN}" "Dotfiles installation completed. Check $LOG_FILE for details."
