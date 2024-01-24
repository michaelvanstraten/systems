return {
	{
		"echasnovski/mini.ai",
		opts = function(_, opts)
			local spec_spair = require("mini.ai").gen_spec.pair

			opts.custom_textobjects["$"] = spec_spair("$", "$", { type = "greedy" })
		end,
	},
}
