# Disable welcome message
set fish_greeting

# Convenience abbreviations
abbr -a c "clear"

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
