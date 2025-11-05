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
                    cpp = { "clang-format" },
                    fish = { "fish_indent" },
                    javascript = { "prettier" },
                    json = { "prettier" },
                    lua = { "stylua" },
                    markdown = { "prettier" },
                    nix = { "nixfmt" },
                    python = { "ruff_format" },
                    rust = { "rustfmt" },
                    sh = { "shfmt" },
                    swift = { "swift_format" },
                    tex = { "latexindent" },
                    toml = { "taplo" },
                    typescript = { "prettier" },
                    typescriptreact = { "prettier" },
                    typst = { "typstyle" },
                    yaml = { "prettier" },
                    meson = { "meson" },
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
