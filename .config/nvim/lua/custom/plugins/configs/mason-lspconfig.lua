local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local mason_lspconfig = require "mason-lspconfig"
---@diagnostic disable-next-line: different-requires
local lspconfig = require "lspconfig"

local function load_opts(server)
    local require_ok, language_settings = pcall(require, "custom.lsp-settings." .. server)

    return {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = require_ok and language_settings or {},
    }
end

mason_lspconfig.setup {
    opts = { ensure_installed = { "lua_ls", "rust_analyzer", "texlab" } },

    handlers = {
        function(server)
            lspconfig[server].setup(load_opts(server))
        end,

        ["lua_ls"] = function() end,
    },
}
