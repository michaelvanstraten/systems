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

opt.spelllang = {
    "en",
    -- "de_20",
}
opt.spell = true

-- Match keywords with hyphen
opt.iskeyword:append "-"
