#!/usr/bin/env sh

# Configuration options
DOTFILES_REPO="https://github.com/michaelvanstraten/dotfiles.git"
BREWFILE="$HOME/.homebrew/Brewfile"

# ANSI escape codes for colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Function to print colored messages
print_message() {
	color="$1"
	message="$2"
	printf "%b%b%b\n" "$color" "$message" "$RESET"
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

# Interact with dotfiles repository
dotfiles() {
	git --git-dir="$HOME/.git/" --work-tree="$HOME" "$@"
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

# Check if OS is compatible.
OS="$(uname)"
if [ "${OS}" != "Linux" ] && [ "${OS}" != "Darwin" ]; then
	exit_with_error "Bootstrap is only supported on macOS and Linux."
fi

# Check if all needed dependencies are available
if ! command_exists "curl"; then
	exit_with_error "cURL is a requirement for installing Homebrew, please make sure it is installed."
elif ! command_exists "bash"; then
	exit_with_error "Bash is a requirement for installing Homebrew, please make sure it is installed."
fi

# Install Homebrew if not installed
if ! command_exists "brew"; then
	print_message "$YELLOW" "Installing Homebrew..."
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1

	case "$(uname -s)" in
	Darwin)
		brew_path="/opt/homebrew/bin/brew"
		;;
	Linux)
		if [ -d "$HOME/.linuxbrew" ]; then
			brew_path="$HOME/.linuxbrew/bin/brew"
		elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
			brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
		else
			exit_with_error "Linuxbrew not found in expected locations."
		fi
		;;
	esac

	# Set Homebrew environment
	eval "$("$brew_path" shellenv)"
else
	print_message "$GREEN" "Homebrew is already installed."
fi

# Clone dotfiles repository if not already
if [ ! -d "$HOME/.git" ]; then
	print_message "$YELLOW" "Bootstraping dotfiles repository."
	git clone --config status.showUntrackedFiles=no --bare --verbose --progress "$DOTFILES_REPO" "$HOME/.git" || exit 1
	dotfiles config --unset core.bare
fi

# Stash any file that checkout would overwrite
if confirm_action "Checkout dotfiles (this will stash any local changes)"; then
	dotfiles diff --quiet HEAD || dotfiles stash push
	dotfiles checkout --progress --recurse-submodules
fi

# Hide readme.md if on macOS
if [ "$(uname -s)" = "Darwin" ]; then
	chflags hidden "$HOME/readme.md"
fi

# Add remote sub-tree repositories
if ! dotfiles remote | grep -q "Betterfox"; then
	dotfiles remote add Betterfox https://github.com/yokoffing/Betterfox
fi

# Install Packages using Brewfile
if [ -f "$BREWFILE" ] && confirm_action "Install homebrew packages from Brewfile"; then
	EDITOR="${EDITOR:-vi}"
	confirm_action "Edit Brewfile before installing" && $EDITOR "$BREWFILE"
	print_message "$GREEN" "Installing packages from Brewfile..."
	brew bundle --file "$BREWFILE" 2>&1 | tee "$LOG_FILE"
else
	print_message "$YELLOW" "No packages to install."
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
