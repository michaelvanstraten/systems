local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting

local sources = {
    formatting.rustfmt,
    formatting.black,
    formatting.prettierd,
}

null_ls.setup {
    autostart = true,
    sources = sources,
}
