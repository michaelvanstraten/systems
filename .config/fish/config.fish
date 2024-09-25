# Disable welcome message
set fish_greeting

# Set Neovim as the default editor
set -Ux EDITOR nvim

# Set common Linux tools config paths
set -Ux XDG_CONFIG_HOME "$HOME/.config"

# Prevent my self from my self (i recently `rm -rf` my home directory)
alias rm="rm -i"

# Basic abbreviations
abbr -a c clear

# Abbreviation for creating a new tmux session with the name of the current directory
abbr -a tn 'tmux new -s (pwd | sed "s/.*\///g")'

# Git abbreviations
abbr -a gc "git clone"

# Replace "ls" with "eza" if available
if command -q eza
    abbr -a l eza
    abbr -a ls eza
    abbr -a la "eza -a"
    abbr -a ll "eza -l"
    abbr -a lla "eza -la"
else
    abbr -a l ls
    abbr -a la "ls -a"
    abbr -a ll "ls -l"
    abbr -a lla "ls -la"
end

# Setup zoxide
if command -q zoxide
    zoxide init fish | source
end

# Initialize starship prompt
if command -q starship
    starship init fish | source
end

# Set Go workspace and add Go binary path to the PATH
set -gx GOPATH "$HOME/.go"
if command -q go
    fish_add_path "$HOME/.go/bin/"
end

# Add ~/.local/bin to the PATH
fish_add_path "$HOME/.local/bin"

# Setup smart tmux session manager
fish_add_path "$HOME/.tmux/plugins/t-smart-tmux-session-manager/bin"

# Setup krew (Krew is the plugin manager for kubectl command-line tool)
fish_add_path "$HOME/.krew/bin"

# Setup podman docker replacement
if command -q podman
     set -gx DOCKER_HOST "unix://$HOME/.local/share/containers/podman/machine/qemu/podman.sock"
end
