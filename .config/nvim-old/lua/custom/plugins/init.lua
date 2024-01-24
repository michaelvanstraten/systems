local lspconfig = require "custom.plugins.configs.lspconfig"

local plugins = {
    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        opts = {},
        config = function()
            require("core.utils").load_mappings "toggleterm"
        end,
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup {}
        end,
    },
    {
        "Pocco81/auto-save.nvim",
        event = { "TextChanged" },
        opts = {
            trigger_events = { "TextChanged", "TextChangedI" },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            auto_install = true,
        },
    },
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format { async = true, lsp_fallback = true }
                end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { { "prettierd", "prettier" } },
            },
        },
    },
    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            git = {
                enable = true,
            },
            renderer = {
                icons = {
                    show = {
                        folder = false,
                    },
                },
            },
            view = {
                centralize_selection = true,
            },
            filters = {
                custom = { "^.git$", "^.dotfiles$" },
            },
            modified = {
                enable = false,
            },
            diagnostics = {
                enable = true,
                severity = {
                    min = vim.diagnostic.severity.WARN,
                },
            },
            actions = {
                open_file = {
                    resize_window = false,
                },
            },
        },
    },
    {
        "toppair/peek.nvim",
        build = "deno task --quiet build:fast",
        cmd = { "PeekOpen", "PeekClose" },
        config = function()
            require("peek").setup()

            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end,
    },
    {
        "Julian/lean.nvim",
        event = { "BufReadPre *.lean", "BufNewFile *.lean" },

        dependencies = {
            "hrsh7th/nvim-cmp",
            "neovim/nvim-lspconfig",
            "nvim-lua/plenary.nvim",
        },
        opts = {
            lsp = {
                on_attach = lspconfig.on_attach,
            },
            mappings = true,
        },
    },
    {
        "williamboman/mason.nvim",
        opts = function()
            local opts = require "plugins.configs.mason"
            opts.ui.border = "rounded"
            return opts
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        init = function()
            require("core.utils").lazy_load "mason-lspconfig.nvim"
        end,
        config = function()
            lspconfig.setup()
        end,
    },

    -- Disabled
    {
        "folke/which-key.nvim",
        enabled = false,
    },
}

return plugins
