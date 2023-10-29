local configs = require "plugins.configs.lspconfig"

local function on_attach(client, bufnr)
    local isFormatingProvider = client.server_capabilities.documentFormattingProvider
    local isRangeFormatingProvider = client.server_capabilities.documentRangeFormattingProvider
    configs.on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = isFormatingProvider
    client.server_capabilities.documentRangeFormattingProvider = isRangeFormatingProvider
end

local function load_config(server)
    local require_ok, settings = pcall(require, "custom.lsp." .. server)

    return {
        on_attach = on_attach,
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
        -- skip `lua_ls` since it is setup by NvChad since it is setup by NvChad
        ["lua_ls"] = function() end,
    },
}
