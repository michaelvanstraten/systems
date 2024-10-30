local function on_client_attach(_, buffer_number)
    local map = vim.keymap.set

    map(
        "n",
        "ca",
        vim.lsp.buf.code_action,
        {
            buffer = buffer_number,
            desc = "Selects a code action available at the current cursor position",
        }
    )
    map(
        "n",
        "cn",
        vim.lsp.buf.rename,
        { buffer = buffer_number, desc = "Renames all references to the symbol under the cursor" }
    )
end

local function make_client_options(opts)
    opts = opts or {}

    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local client_capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
    )

    return vim.tbl_deep_extend("force", {
        capabilities = client_capabilities,
        on_attach = on_client_attach,
    }, opts or {})
end

return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
        { "folke/neoconf.nvim", cmd = "Neoconf", opts = {}, dependencies = { "nvim-lspconfig" } },
        { "folke/neodev.nvim", opts = {} },
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local lspconfig = require("lspconfig")

        lspconfig.lua_ls.setup(make_client_options({
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
        }))
        lspconfig.texlab.setup(make_client_options())
        lspconfig.rust_analyzer.setup(make_client_options())
        lspconfig.nixd.setup(make_client_options())
        lspconfig.yamlls.setup(make_client_options())
        lspconfig.pyright.setup(make_client_options())
        lspconfig.clangd.setup(make_client_options())
        lspconfig.ltex.setup(make_client_options())
    end,
}
