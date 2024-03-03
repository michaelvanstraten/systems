return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		keys = {
			{
				"<leader>ka",
				"<cmd>Copilot attach<cr>",
				mode = { "n" },
				desc = "Attach to the current buffer",
			},
			{
				"<leader>k",
				"<cmd>Copilot panel<cr>",
				mode = { "n" },
				desc = "Open Copilot panel",
			},
		},
		opts = {
			panel = {
				auto_refresh = true,
				keymap = {
					jump_next = "j",
					jump_prev = "k",
				},
				layout = {
					position = "right",
				},
			},
			suggestion = {
				enabled = false,
				auto_trigger = true,
			},
		},
	},
}
