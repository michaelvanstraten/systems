# Disable welcome message
set fish_greeting

set -Ux EDITOR nvim # Use neovim as default editor

# Convenience abbreviations
abbr -a c "clear" 
abbr -a vim "nvim" # vim to nvim
abbr -a npm "pnpm" # npm to pnpm
abbr -a tn "tmux new -s (pwd | sed 's/.*\///g')" # new tmux session with the name of the current dir


# Setup zoxide
if command -q zoxide
    zoxide init fish | source 
end

# Setup smart tmux session manager
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin

# Replacing "ls" with "eza"
if command -q eza
	abbr -a l "eza"
	abbr -a ls "eza"
	abbr -a la "eza -a"
	abbr -a ll "eza -l"
	abbr -a lla "eza -la"
else
	abbr -a l "ls"
	abbr -a la "ls -a"
	abbr -a ll "ls -l"
	abbr -a lla "ls -la"
end

# pyenv init
if command -q pyenv
    pyenv init - | source
end

# dotfiles git repo alias 
function dotfiles --wraps git
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end
