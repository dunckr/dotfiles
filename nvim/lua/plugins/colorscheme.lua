return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "dark", -- Options: 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer'
			})
			require("onedark").load()
		end,
	},
}
