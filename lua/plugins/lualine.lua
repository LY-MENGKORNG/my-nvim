return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function(_, opts)
			table.insert(opts.sections.lualine_x, {
				function()
					return "🦄"
				end,
			})
			-- add more custom lualine config here
		end,
	},
}
