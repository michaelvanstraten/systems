#!/usr/bin/env sh

# Configuration options
DOTFILES_REPO="https://github.com/michaelvanstraten/dotfiles.git"
BREWFILE="$HOME/.homebrew/Brewfile"
BACKUP_DIR="$HOME/.dotfiles-backup"
LOG_FILE="$HOME/.dotfiles-install.log"

# ANSI escape codes for colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Function to print colored messages
print_message() {
    color="$1"
    message="$2"
    printf "%s%s%s\n" "$color" "$message" "$RESET"
}

# Function to print an error message and exit
exit_with_error() {
    print_message "$RED" "Error: $1"
    exit 1
}

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Define a function to work with dotfiles
dotfiles() {
    git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# Function to confirm actions interactively
confirm_action() {
    prompt="$1"
    printf "%s (y/N): " "$prompt"
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        return 0
    else
        return 1
    fi
}

# Function to install Homebrew if not installed
install_homebrew() {
    if ! command_exists "brew"; then
        print_message "$YELLOW" "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        print_message "$GREEN" "Homebrew is already installed."
    fi
}

# Function to handle dotfiles installation
install_dotfiles() {
    # Clone dotfiles repository
    if [ -d "$HOME/.dotfiles" ]; then
        print_message "$GREEN" "Dotfiles repository already exists. Skipping clone."
    else
        print_message "$YELLOW" "Cloning dotfiles repository."
        git clone --bare "$DOTFILES_REPO" "$HOME/.dotfiles" >> "$LOG_FILE" 2>&1
    fi

    # Handle existing dotfiles backup
    if [ -d "$BACKUP_DIR" ]; then
        confirm_action "There already exists a backup of your dotfiles, proceeding would delete that backup." || return
        rm -r "$BACKUP_DIR"
    fi

    # Attempt to checkout dotfiles
    if [ -d "$HOME/.dotfiles" ]; then
        mkdir -p "$BACKUP_DIR"
        dotfiles checkout 2>&1 | while read -r file; do
            if echo "$file" | grep -q "already exists"; then
                print_message "$RED" "Backing up pre-existing dotfiles."
                dotfiles checkout 2>&1 | awk '/\s+\./ {print $1}' | xargs -I{} mv {} "$BACKUP_DIR/{}"
                break
            fi
        done
    fi

    # Set status.showUntrackedFiles to no to ignore untracked files
    dotfiles config status.showUntrackedFiles no

    # Hide readme.md if on macOS
    if [ "$(uname -s)" = "Darwin" ]; then
        chflags hidden "$HOME/readme.md"
    fi

    # Add remote sub-tree repositories
    if ! dotfiles remote | grep -q "NvChad"; then
        dotfiles remote add NvChad https://github.com/NvChad/NvChad
    fi
    if ! dotfiles remote | grep -q "Betterfox"; then
        dotfiles remote add Betterfox https://github.com/yokoffing/Betterfox
    fi
}

install_homebrew
install_dotfiles

# Install Packages using Brewfile
if [ -f "$BREWFILE" ] && confirm_action "Install homebrew packages from Brewfile"; then
    EDITOR="${EDITOR:-vi}"
    confirm_action "Edit Brewfile before installing" && $EDITOR "$BREWFILE"
    print_message "$GREEN" "Installing packages from Brewfile..."
    brew bundle --file "$BREWFILE" 2>&1 | tee "$LOG_FILE"
else
    print_message "$YELLOW" "No packages to install."
fi

if command_exists "fish" && confirm_action "Set fish as the default shell"; then
    print_message "$YELLOW" "Changing default shell to fish (You will have to logout and log back in for this to take effect)."
    sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
    chsh -s /opt/homebrew/bin/fish
fi

# Install tmux plugin manager (tpm) if tmux is installed
if command_exists "tmux"; then
    print_message "$YELLOW" "Installing tmux plugin manager."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

os_config="$HOME/.scripts/sys/$(uname | tr '[:upper:]' '[:lower:]').sh"
if [ -f "$os_config" ] && confirm_action "Set os specific configuration"; then
    . "$os_config"
fi

print_message "$GREEN" "Dotfiles installation completed. Check $LOG_FILE for details."

# Log user out for settings to take effect
if [ "$(uname -s)" = "Darwin" ] && confirm_action "You may want to logout and log back in for many settings to take effect."; then
    osascript -e 'tell app "System Events" to log out'
fi
