require "custom.autocmds"

local opt = vim.opt

-- Indenting
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

-- Numbers
opt.relativenumber = true

-- Disable swap file
opt.swapfile = false

-- Hide status line
-- opt.laststatus = 0

-- Enable spell checking
opt.spelllang = {
    "en",
}
opt.spell = true

-- Match keywords with hyphen
opt.iskeyword:append "-"
