return {
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				sources = {
					explorer = {
						hidden = true,
						ignored = true,
					},
					files = {
						hidden = true, -- Show hidden/dotfiles
						ignored = true, -- Optional: show gitignored files
					},
				},
			},
		},
	},
}
