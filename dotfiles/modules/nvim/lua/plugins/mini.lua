return {
    {
        "nvim-mini/mini.nvim",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("mini.ai").setup({
                custom_textobjects = {
                    ["$"] = require("mini.ai").gen_spec.pair("$", "$", { type = "greedy" }),
                },
            })

            require("mini.pairs").setup({})

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "tex,typst",
                callback = function()
                    MiniPairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "rust",
                callback = function()
                    vim.keymap.set("i", "'", "'", { buffer = true, noremap = true })
                end,
            })

            require("mini.surround").setup({

                custom_surroundings = {
                    ["("] = {
                        input = { "%b()", "^.%s*().-()%s*.$" },
                        output = { left = "(", right = ")" },
                    },
                    ["["] = {
                        input = { "%b[]", "^.%s*().-()%s*.$" },
                        output = { left = "[", right = "]" },
                    },
                    ["{"] = {
                        input = { "%b{}", "^.%s*().-()%s*.$" },
                        output = { left = "{", right = "}" },
                    },
                    ["<"] = {
                        input = { "%b<>", "^.%s*().-()%s*.$" },
                        output = { left = "<", right = ">" },
                    },
                },
            })
        end,
    },
}
