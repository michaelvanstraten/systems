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
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        init = function()
            require("core.utils").lazy_load "mason-lspconfig.nvim"
        end,
        config = function()
            ---@diagnostic disable-next-line: different-requires
            require "custom.plugins.configs.lspconfig"
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
