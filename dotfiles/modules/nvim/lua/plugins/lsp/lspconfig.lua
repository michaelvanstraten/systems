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
            clangd = {},
            harper_ls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        codeLens = { enable = true },
                        completion = { callSnippet = "Replace" },
                    },
                },
            },
            nil_ls = {},
            pyright = {},
            rust_analyzer = {},
            taplo = {},
            texlab = {},
            tinymist = {},
            ts_ls = {},
            yamlls = {},
        },
    },
    config = function(_, opts)
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

            vim.lsp.config(server, config)
            vim.lsp.enable(server)
        end
    end,
}
