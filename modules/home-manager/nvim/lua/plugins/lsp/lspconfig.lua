vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
    anchor_bias = "above",
    max_height = math.floor(vim.o.lines * 0.5),
    max_width = math.floor(vim.o.columns * 0.75),
})

return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
        { "folke/neoconf.nvim", cmd = "Neoconf", opts = {}, dependencies = { "nvim-lspconfig" } },
        { "folke/neodev.nvim", opts = {} },
        "saghen/blink.cmp",
    },
    opts = {
        servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        workspace = {
                            checkThirdParty = false,
                        },
                        codeLens = {
                            enable = true,
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            },
            texlab = {},
            rust_analyzer = {},
            nixd = {},
            yamlls = {},
            clangd = {},
            pylsp = {},
            ltex = {},
        },
    },
    config = function(_, opts)
        local lspconfig = require("lspconfig")
        for server, config in pairs(opts.servers) do
            local blink = require("blink.cmp")

            config.capabilities = blink.get_lsp_capabilities(config.capabilities)
            config.on_client_attach = function(_, buffer_number)
                local map = vim.keymap.set
                map("n", "ca", vim.lsp.buf.code_action, {
                    buffer = buffer_number,
                    desc = "Selects a code action available at the current cursor position",
                })
                map("n", "cn", vim.lsp.buf.rename, {
                    buffer = buffer_number,
                    desc = "Renames all references to the symbol under the cursor",
                })
            end

            lspconfig[server].setup(config)
        end
    end,
}
