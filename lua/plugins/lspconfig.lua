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
}
