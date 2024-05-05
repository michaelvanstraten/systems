return {
	"Julian/lean.nvim",
	event = { "BufReadPre *.lean", "BufNewFile *.lean" },

	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp"
	},

	opts = {
		mappings = true,
	},
}
