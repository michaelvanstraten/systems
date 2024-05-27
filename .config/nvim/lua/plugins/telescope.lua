return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
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
			"<leader>ss",
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
		{
			"<leader>rg",
			function()
				local builtin = require("telescope.builtin")
				builtin.live_grep()
			end,
			desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore. (Requires ripgrep)",
		},
	},
	opts = {},
}
