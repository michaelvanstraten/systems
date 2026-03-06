return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        highlight = {
            enable = true,
            disable = { "dockerfile" },
        },
        indent = { enable = false },
        auto_install = true,
    },
    config = function(_, opts)
        require("nvim-treesitter").setup(opts)
    end,
}
