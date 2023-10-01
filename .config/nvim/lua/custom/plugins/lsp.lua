local plugins = {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "williamboman/mason-lspconfig.nvim",
                dependencies = "williamboman/mason.nvim",

                config = function(_, _)
                    require "custom.plugins.configs.mason-lspconfig"
                end,
            },
            {
                "jose-elias-alvarez/null-ls.nvim",
                dependencies = {
                    "jay-babu/mason-null-ls.nvim",
                    dependencies = "williamboman/mason.nvim",
                    config = function(_, _)
                        require "custom.plugins.configs.mason-null-ls"
                    end,
                },
                config = function(_, _)
                    require "custom.plugins.configs.null-ls"
                end,
            },
        },
    },
}

return plugins
