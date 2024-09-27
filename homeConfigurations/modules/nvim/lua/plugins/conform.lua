return {
    {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format()
                end,
                mode = { "n", "v" },
                desc = "Format the buffer",
            },
        },
        opts = function()
            return {
                formatters_by_ft = {
                    lua = { "stylua" },
                    fish = { "fish_indent" },
                    sh = { "shfmt" },
                    python = { "black" },
                    tex = { "latexindent" },
                    nix = { "nixfmt" },
                    markdown = { "prettier" },
                    yaml = { "prettier" },
                    cpp = { "clang-format" },
                    json = { "prettier" },
                },
                formatters = {
                    latexindent = {
                        args = { "-m", "-l", "-" },
                        cwd = require("conform.util").root_file({ ".latexindent.yaml" }),
                    },
                    prettier = {
                        prepend_args = { "--prose-wrap", "always" },
                    },
                },
            }
        end,
    },
}
