return {
    {
        "echasnovski/mini.ai",
        event = "VeryLazy",
        opts = function()
            local ai = require("mini.ai")

            return {
                custom_textobjects = {
                    ["$"] = ai.gen_spec.pair("$", "$", { type = "greedy" }),
                },
            }
        end,
    },
    {
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        config = function()
            require("mini.pairs").setup({})

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "tex,typst",
                callback = function()
                    MiniPairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })
                end,
            })
        end,
    },
    {
        "echasnovski/mini.surround",
        event = "VeryLazy",
        opts = {
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
        },
    },
}
