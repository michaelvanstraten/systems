switch (uname -s)
    case 'Darwin'
        set brew_path "/opt/homebrew/bin/brew"
    case 'Linux'
        set brew_path "/home/linuxbrew/.linuxbrew/bin/brew"
    case '*'
        echo "Unsupported operating system"
        return
end

# Set Homebrew environment
eval "$($brew_path shellenv)"

# Disable auto-update
set -gx HOMEBREW_NO_AUTO_UPDATE 1
