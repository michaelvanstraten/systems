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
            {
                "<leader>F",
                function()
                    require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
                end,
                mode = { "n", "v" },
                desc = "Format Injected Langs",
            },
        },
        opts = function()
            return {
                default_format_opts = {
                    timeout_ms = 3000,
                    async = false,
                    quiet = false,
                },
                formatters_by_ft = {
                    lua = { "stylua" },
                    fish = { "fish_indent" },
                    sh = { "shfmt" },
                    python = { "ruff_format" },
                    tex = { "latexindent" },
                    nix = { "nixfmt" },
                    markdown = { "prettier" },
                    yaml = { "prettier" },
                    cpp = { "clang-format" },
                    json = { "prettier" },
                    toml = { "taplo" },
                    typst = { "typstyle" },
                    swift = { "swift_format" },
                    rust = { "rustfmt" },
                },
                formatters = {
                    injected = { options = { ignore_errors = true } },
                    latexindent = {
                        args = { "-m", "-l", "-" },
                        cwd = require("conform.util").root_file({ ".latexindent.yaml" }),
                    },
                    prettier = {
                        prepend_args = { "--prose-wrap", "always" },
                    },
                    typestyle = {
                        append_args = { "--wrap-text" },
                    },
                },
            }
        end,
    },
}
