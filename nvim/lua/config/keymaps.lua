local map = vim.keymap.set

-- Leader key (already set in init.lua, but document here)
-- vim.g.mapleader = ","

-- Basic mappings
map("n", "<Leader>w", "<ESC>:w<CR>", { desc = "Save file" })
map("n", "<C-e>", ":Neotree toggle<CR>", { desc = "Toggle file tree" })
map("n", "H", "^", { desc = "Jump to line start" })
map("n", "L", "$", { desc = "Jump to line end" })
map("n", "<Leader>t", ":set expandtab<CR>", { desc = "Enable expand tab" })
map("n", "<Leader>r", ":source $MYVIMRC<CR>", { desc = "Reload config" })

-- Tmux navigation
map("n", "<BS>", ":TmuxNavigateLeft<CR>", { silent = true, desc = "Tmux navigate left" })

-- Telescope (replacing fzf)
map("n", "<C-p>", ":Telescope git_files<CR>", { silent = true, desc = "Find git files" })
map("n", "<C-t>", ":Telescope tags<CR>", { silent = true, desc = "Find tags" })

-- Search (replacing CtrlSF - using Telescope live_grep)
map("n", "<C-F>", ":Telescope live_grep<CR>", { desc = "Live grep search" })

-- Format with Prettier (for specific filetypes)
map(
	"n",
	"<leader>p",
	":silent %!prettier --stdin --trailing-comma es5 --tab-width 2 --use-tabs --single-quote --print-width 120 --parser typescript<CR>",
	{ desc = "Format with Prettier" }
)

-- VSCode integration
if vim.g.vscode then
	map("n", "<leader>e", "<Cmd>lua require('vscode').action('workbench.view.explorer')<CR>", { desc = "VSCode: Explorer" })
	map("n", "<leader>a", "<Cmd>lua require('vscode').action('test-switcher.switch')<CR>", { desc = "VSCode: Test switcher" })
	map("n", "<leader>c", "<Cmd>lua require('vscode').action('editor.action.commentLine')<CR>", { desc = "VSCode: Comment line" })
	map("n", "<leader>`", "<Cmd>lua require('vscode').action('vscode-neovim.restart')<CR>", { desc = "VSCode: Restart Neovim" })
end

-- LSP keymaps (will be set up in LSP config when buffer attaches)
-- These are documented here for reference:
-- gd - Go to definition
-- gr - Go to references
-- K - Hover documentation
-- <leader>rn - Rename symbol
-- <leader>ca - Code action
-- [d - Previous diagnostic
-- ]d - Next diagnostic
