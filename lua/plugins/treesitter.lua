return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"bash",
				"lua",
				"rust",
				"zig",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"html",
				"javascript",
				"typescript",
				"json",
				"vue",
				"tsx",
				"svelte",
				"vim",
				"yaml",
			},
		},
	},
	-- {
	-- 	"nvim-treesitter/nvim-treesitter",
	-- 	opts = function(_, opts)
	-- 		-- add tsx and treesitter
	-- 		vim.list_extend(opts.ensure_installed, {
	-- 			"tsx",
	-- 			"typescript",
	-- 		})
	-- 	end,
	-- },
}
