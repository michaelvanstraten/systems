# Disable welcome message
set fish_greeting

set -Ux EDITOR nvim # Use neovim as default editor
set -Ux XDG_CONFIG_HOME "$HOME/.config" # Set to common Linux tools recognise config paths

# Convenience abbreviations
abbr -a c clear
abbr -a vim nvim # vim to nvim
abbr -a npm pnpm # npm to pnpm
abbr -a tn "tmux new -s (pwd | sed 's/.*\///g')" # new tmux session with the name of the current dir
abbr -a k kubectl

# git abbreviations
abbr -a gs "git status"
abbr -a gl "git log"
abbr -a gc "git commit"
abbr -a gr "git rebase"

# Replacing "ls" with "eza"
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

# pyenv init
if command -q pyenv
    pyenv init - | source
end

# Setup starship
if command -q starship
    starship init fish | source
end

# Setup smart tmux session manager
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin
