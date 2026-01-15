local autocmd = vim.api.nvim_create_autocmd

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- Git commit settings
autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.textwidth = 72
	end,
})

-- Prettier format mapping for specific filetypes
-- The keymap is already defined in keymaps.lua
-- This autocmd is just for documentation purposes - no additional setup needed
