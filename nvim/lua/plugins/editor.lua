return {
	-- Indent guides (modern replacement for vim-indent-guides)
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
				},
				scope = {
					enabled = false,
				},
			})
		end,
	},

	-- Auto pairs (modern replacement for delimitMate)
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
			-- Integrate with nvim-cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- EditorConfig support
	{
		"editorconfig/editorconfig-vim",
	},

	-- Hardtime (already Lua-based)
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- Large file handling
	{
		"LunarVim/bigfile.nvim",
		config = function()
			require("bigfile").setup()
		end,
	},

	-- Auto-close structures
	{
		"tpope/vim-endwise",
	},
}
