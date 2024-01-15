# Disable auto-update
set -gx HOMEBREW_NO_AUTO_UPDATE 1

if not status --is-login
    return
end

switch (uname -s)
    case Darwin
        set brew_path /opt/homebrew/bin/brew
    case Linux
        if test -d ~/.linuxbrew
            set brew_path ~/.linuxbrew/bin/brew
        else if test -d /home/linuxbrew/.linuxbrew
            set brew_path /home/linuxbrew/.linuxbrew/bin/brew
        else
            echo "Linuxbrew not found in expected locations."
            return
        end
    case '*'
        echo "Unsupported operating system"
        return
end

# Set Homebrew environment
eval "$($brew_path shellenv)"
