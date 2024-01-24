return {
	"nvim-telescope/telescope.nvim",
	keys = {
		-- press "?" to show key maps
		{ "?", "<cmd>Telescope keymaps<cr>", desc = "Show keymaps" },
		-- "<leader>ss" to spell suggest word
		{ "<leader>ss", "<cmd>Telescope spell_suggest<cr>", desc = "Spell suggest" },
	},
}
