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
		echo "Linuxbrew not found in expected locations." >&2
	fi
	;;
esac

# Set Homebrew environment
[ -z "$brew_path" ] && eval "$("$brew_path" shellenv)"

. "$HOME/.cargo/env"
