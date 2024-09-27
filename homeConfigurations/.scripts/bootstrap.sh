#!/bin/sh

# Configuration options
DOTFILES_REPO="https://github.com/michaelvanstraten/dotfiles.git"
BREWFILE="$HOME/.homebrew/Brewfile"

# String formatters
if [ -t 1 ]; then
	tty_escape() { printf "\033[%sm" "$1"; }
else
	tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_yellow="$(tty_mkbold 33)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

print_heading() {
	printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$@"
}

warn() {
	printf "${tty_yellow}Warning${tty_reset}: %s\n" "$1" >&2
}

abort() {
	printf "${tty_red}Error${tty_reset}: %s\n" "$1" >&2
	exit 1
}

# Function to check if a command is available
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to confirm actions interactively
confirm_action() {
	printf "${tty_blue}Confirm:${tty_reset} %s (y/N): " "$1"
	read -r response
	if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
		return 0
	else
		return 1
	fi
}

check_dependencies() {
	for dep in "$@"; do
		if ! command_exists "$dep"; then
			abort "${tty_yellow}$dep${tty_reset} is a required dependency. Please install it and run this script again."
		fi
	done
}

main() {
	# Check if OS is compatible.
	OS="$(uname)"
	if [ "${OS}" != "Linux" ] && [ "${OS}" != "Darwin" ]; then
		abort "This script is only supported on macOS and Linux."
	fi

	if confirm_action "Install Homebrew"; then
		check_dependencies "bash" "curl" "git"
		install_homebrew
	fi

    bootstrap_dotfiles

	confirm_action "Install Homebrew packages from Brewfile" && install_brewfile

	confirm_action "Make fish your default shell" && make_fish_default_shell

	os_config="$HOME/.scripts/sys/$(uname | tr '[:upper:]' '[:lower:]').sh"
	if [ -f "$os_config" ] && confirm_action "Set OS-specific configuration"; then
		. "$os_config"
	fi

	echo "Dotfiles Bootstrap completed."

	# Suggest logging out for settings to take effect
	if [ "$(uname -s)" = "Darwin" ] && confirm_action "Logout current user for some settings to take effect"; then
		osascript -e 'tell app "System Events" to log out'
	fi
}

# Installs Homebrew if not already installed
install_homebrew() {
	if ! command_exists "brew"; then
		print_heading "Installing Homebrew ..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || abort "Failed to install Homebrew."

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
				abort "Linuxbrew not found in expected locations."
			fi
			;;
		esac

		# Set Homebrew environment
		eval "$("$brew_path" shellenv)"
	else
		echo "Homebrew is already installed."
	fi
}

# Interact with dotfiles repository
dotfiles() {
	git --git-dir="$HOME/.git/" --work-tree="$HOME" "$@"
}

bootstrap_dotfiles() {
	# Clone dotfiles repository if not already
	if [ ! -d "$HOME/.git" ]; then
		print_heading "Bootstrapping dotfiles repository ..."
		git clone --bare --verbose --progress "$DOTFILES_REPO" "$HOME/.git" || abort "Failed to clone dotfiles repository."
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

}

# Install Packages using Brewfile
install_brewfile() {
	if [ -f "$BREWFILE" ]; then
		EDITOR="${EDITOR:-vi}"
		confirm_action "Edit Brewfile before installing" && $EDITOR "$BREWFILE"
		print_heading "Installing packages from Brewfile ..."
		brew bundle --file "$BREWFILE"
	else
		echo "No Homebrew packages to install."
	fi
}

make_fish_default_shell() {
	if command_exists "fish"; then
		fish_path=$(command -v fish)
		echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
		chsh -s "$fish_path" "$USER"
	fi
}

main "$@" || exit 1
