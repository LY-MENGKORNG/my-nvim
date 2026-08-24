return {
	"neovim/nvim-lspconfig",
	opts = {
		servers = {
			dartls = {
				-- Optional: Custom command if 'dart' is not in PATH
				-- cmd = { "dart", "language-server", "--protocol=lsp" },
				settings = {
					dart = {
						completeFunctionCalls = true,
						showTodos = true,
						-- lineLength = 80, -- Default is 80
					},
				},
			},
		},
	},
}
