# Disable welcome message
set fish_greeting

set -Ux EDITOR nvim # Use neovim as default editor

# Convenience abbreviations
abbr -a c "clear" 
abbr -a vim "nvim" # vim to nvim
abbr -a npm "pnpm" # npm to pnpm
abbr -a tn "tmux new -s (pwd | sed 's/.*\///g')" # new tmux session with the name of the current dir


# Setup zoxide
zoxide init fish | source 

# Setup smart tmux session manager
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin

# Replacing "exa" with "ls"
if command -v exa > /dev/null
	abbr -a l "exa"
	abbr -a ls "exa"
	abbr -a la "exa -a"
	abbr -a ll "exa -l"
	abbr -a lla "exa -la"
else
	abbr -a l "ls"
	abbr -a la "ls -a"
	abbr -a ll "ls -l"
	abbr -a lla "ls -la"
end

# pyenv init
if command -v pyenv 1>/dev/null 2>&1
    pyenv init - | source
end

# dotfiles git repo alias 
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
