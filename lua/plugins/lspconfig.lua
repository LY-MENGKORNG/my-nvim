return {
	-- Use vtsls (modern TypeScript LSP) instead of deprecated tsserver + typescript.nvim
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				vtsls = {
					settings = {
						vtsls = {
							tsserver = {
								globalPlugins = {
									{
										name = "typescript-svelte-plugin",
										location = LazyVim.get_pkg_path("svelte-language-server", "/node_modules/typescript-svelte-plugin"),
										enableForWorkspaceTypeScriptVersions = true,
									},
								},
							},
						},
					},
				},
				pyright = {},
				svelte = {},
			},
		},
	},
	-- TypeScript support via modern typescript-tools.nvim (replaces deprecated typescript.nvim)
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {},
		config = function(_, opts)
			require("typescript-tools").setup(opts)
			-- Set up keymaps after LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "typescript-tools" then
						local buf = args.buf
						vim.keymap.set("n", "<leader>co", "<cmd>TSLintFixAll<cr>", { buffer = buf, desc = "Organize Imports" })
						vim.keymap.set("n", "<leader>cR", "<cmd>TSToolsRenameFile<cr>", { buffer = buf, desc = "Rename File" })
					end
				end,
			})
		end,
	},
}
