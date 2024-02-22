return {
	{
		"stevearc/conform.nvim",
		keys = {
			{
				"<leader>fI",
				function()
					require("conform").format({ formatters = { "injected" } })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		opts = function(_, opts)
			opts.formatters_by_ft["python"] = { "black" }
			opts.formatters_by_ft["markdown"] = { "mdformat" }
			opts.formatters_by_ft["cpp"] = { "clang-format" }
		end,
	},
}
