return {
	"neovim/nvim-lspconfig",
	event = "VeryLazy",
	dependencies = {
		{ "folke/neoconf.nvim", cmd = "Neoconf", opts = {}, dependencies = { "nvim-lspconfig" } },
		{ "folke/neodev.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_nvim_lsp.default_capabilities()
		)

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					workspace = {
						checkThirdParty = false,
					},
					codeLens = {
						enable = true,
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})
		lspconfig.texlab.setup({ capabilities = capabilities })
		lspconfig.rust_analyzer.setup({
			capabilities = capabilities,
		})
		lspconfig.nil_ls.setup({ capabilities = capabilities })
		lspconfig.yamlls.setup({ capabilities = capabilities })
		lspconfig.pyright.setup({ capabilities = capabilities })
	end,
}
