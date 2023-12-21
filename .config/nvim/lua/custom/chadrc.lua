---@diagnostic disable: missing-fields
---@type ChadrcConfig
local M = {}

M.lazy_nvim = {
    change_detection = {
        notify = false
    }
}

M.ui = {
    theme = "ayu_dark",
    transparency = true,
    lsp = {
        semantic_tokens = true,
    },
    telescope = { style = "bordered" },
    tabufline = {
        enabled = false,
        overriden_modules = function(modules)
            table.remove(modules, 4)
        end,
    },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.keymap"

return M
