return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	version = false, -- telescope did only one release, so use HEAD for now
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader><space>",
			function()
				local builtin = require("telescope.builtin")
				builtin.find_files()
			end,
			desc = "Lists files in your current working directory, respects .gitignore",
		},
		{
			"?",
			function()
				local builtin = require("telescope.builtin")
				builtin.keymaps()
			end,
			desc = "Lists normal mode keymappings",
		},
		{
			"ss",
			function()
				local builtin = require("telescope.builtin")
				builtin.spell_suggest()
			end,
			desc = "Lists spelling suggestions for the current word under the cursor, replaces word with selected suggestion on `<cr>`.",
		},
		{
			"gd",
			function()
				local builtin = require("telescope.builtin")
				builtin.lsp_definitions()
			end,
			desc = "Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope.",
		},
		{
			"gr",
			function()
				local builtin = require("telescope.builtin")
				builtin.lsp_references()
			end,
			desc = "Lists LSP references for word under the cursor.",
		},
	},
	opts = {},
}
