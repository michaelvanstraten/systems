# Disable welcome message
set fish_greeting

# Convenience abbreviations
abbr -a c "clear"

# vim to nvim
abbr -a vim "nvim"

# npm to pnpm
abbr -a npm "pnpm"

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

