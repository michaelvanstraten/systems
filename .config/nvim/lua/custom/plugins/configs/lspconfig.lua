local configs = require "plugins.configs.lspconfig"

local function load_config(server)
    local require_ok, settings = pcall(require, "custom.lsp." .. server)

    return {
        on_attach = configs.on_attach,
        capabilities = configs.capabilities,
        settings = require_ok and settings or {},
    }
end

require("mason-lspconfig").setup {
    opts = { ensure_installed = { "lua_ls", "rust_analyzer" } },

    handlers = {
        function(server)
            ---@diagnostic disable-next-line: different-requires
            require("lspconfig")[server].setup(load_config(server))
        end,
        ["lua_ls"] = function() end, -- skip `lua_ls` since it is setup by NvChad since it is setup by NvChad
    },
}
