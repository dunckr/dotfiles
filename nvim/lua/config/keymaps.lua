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

-- Split navigation (<C-h/j/k/l> across nvim, tmux and herdr-app) lives in
-- lua/plugins/navigation.lua

-- Jumplist: <D-[> pops back to where you were (e.g. after gd), <D-]> goes
-- forward again. Needs the terminal to forward cmd-modified keys as CSI u
-- (see readme); guarded so VSCode keeps cmd+[ for previousEditor.
if not vim.g.vscode then
	map({ "n", "v" }, "<D-[>", "<C-o>", { desc = "Jump back" })
	map({ "n", "v" }, "<D-]>", "<C-i>", { desc = "Jump forward" })

	-- <D-1> toggles the file tree, like cmd+1 for the project view in JetBrains.
	map("n", "<D-1>", "<Cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })

	-- IdeaVim equivalents (see home/.ideavimrc). LSP ones live in
	-- lua/plugins/lsp.lua since they only make sense with a server attached.
	map("n", "]c", function()
		if vim.wo.diff then
			vim.cmd.normal({ "]c", bang = true })
		else
			require("gitsigns").nav_hunk("next")
		end
	end, { desc = "Next changed hunk" })
	map("n", "[c", function()
		if vim.wo.diff then
			vim.cmd.normal({ "[c", bang = true })
		else
			require("gitsigns").nav_hunk("prev")
		end
	end, { desc = "Previous changed hunk" })
	map("n", "<Leader>gb", function()
		require("gitsigns").blame()
	end, { desc = "Git blame" })
	map("n", "<Leader>gw", function()
		require("gitsigns").diffthis("main")
	end, { desc = "Compare with main" })

	map("n", "<Leader>c<Space>", "gcc", { remap = true, desc = "Toggle comment" })
	map("v", "<Leader>c<Space>", "gc", { remap = true, desc = "Toggle comment" })

	local function repo_path()
		local file = vim.fn.expand("%:p")
		local root = vim.fs.root(file, ".git")
		if not root then
			return nil, nil
		end
		return root, file:sub(#root + 2)
	end

	map("n", "<Leader>cf", function()
		local _, rel = repo_path()
		if not rel then
			return vim.notify("Not in a git repo", vim.log.levels.WARN)
		end
		vim.fn.setreg("+", rel)
		vim.notify("Copied " .. rel)
	end, { desc = "Copy path from repo root" })

	map("n", "<Leader>go", function()
		local root, rel = repo_path()
		if not rel then
			return vim.notify("Not in a git repo", vim.log.levels.WARN)
		end
		vim.system({ "gh", "browse", rel .. ":" .. vim.fn.line(".") }, { cwd = root })
	end, { desc = "Open in GitHub" })

	-- <leader>a switches between a file and its test, like the VSCode
	-- test-switcher binding below.
	map("n", "<Leader>a", function()
		require("config.test-switcher").switch()
	end, { desc = "Switch to test/source" })
end

-- Telescope (replacing fzf)
map("n", "<C-p>", ":Telescope git_files<CR>", { silent = true, desc = "Find git files" })
map("n", "<C-t>", ":Telescope tags<CR>", { silent = true, desc = "Find tags" })

-- Project search: live grep from the git root of the current buffer (or cwd
-- outside a repo). rg skips gitignored files; hidden files are searched but
-- .git itself is not (see vimgrep_arguments in lua/plugins/telescope.lua).
local function grep_project(opts)
	opts = opts or {}
	opts.cwd = vim.fs.root(0, ".git") or vim.fn.getcwd()
	require("telescope.builtin").live_grep(opts)
end

-- Search (replacing CtrlSF - using Telescope live_grep)
map("n", "<C-F>", grep_project, { desc = "Search in project" })

-- <D-f> searches the whole project, like Find in Files in JetBrains. herdr-app
-- sends cmd+f as CSI u (see home/.config/herdr-app/keys.json). In visual mode
-- the selection is the starting query.
map("n", "<D-f>", grep_project, { desc = "Search in project" })
map("v", "<D-f>", function()
	local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
	grep_project({ default_text = table.concat(lines, " ") })
end, { desc = "Search selection in project" })

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
