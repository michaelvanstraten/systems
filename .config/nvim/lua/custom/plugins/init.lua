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
            filters = {
                custom = { "^.git$", "^.dotfiles$" },
            },
            diagnostics = {
                enable = true,
                severity = {
                    min = vim.diagnostic.severity.WARN,
                },
            },
                },
            },
        },
    },
}

return plugins
