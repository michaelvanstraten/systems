return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{
			"<leader>e",
			function()
				require("nvim-tree.api").tree.toggle()
			end,
			desc = "Toggle file explorer (NvimTree)",
		},
	},
	opts = {
		on_attach = function(buffer)
			local api = require("nvim-tree.api")

			local function opts(desc)
				return { desc = "nvim-tree: " .. desc, buffer = buffer, noremap = true, silent = true, nowait = true }
			end

			api.config.mappings.default_on_attach(buffer)

			vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
		end,
		hijack_cursor = true,
		view = {
			preserve_window_proportions = true,
			width = {
				min = 30,
				max = -1,
			},
		},
		renderer = {
			root_folder_label = false,
			indent_markers = {
				enable = true,
				inline_arrows = true,
			},
			icons = {
				show = {
					folder = false,
				},
			},
		},
		git = { enable = false },
	},
}
