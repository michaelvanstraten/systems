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
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
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
    {
        "jay-babu/mason-null-ls.nvim",
        init = function()
            require("core.utils").lazy_load "mason-null-ls.nvim"
        end,
        dependencies = {
            "williamboman/mason.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
        config = function()
            require "custom.plugins.configs.null-ls"
        end,
    },
}

return plugins
