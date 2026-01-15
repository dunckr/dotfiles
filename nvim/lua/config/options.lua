local opt = vim.opt

-- File format
opt.fileformat = "unix"

-- Color scheme settings
vim.g.nvim_tui_enable_true_color = 1
opt.termguicolors = true
vim.cmd("syntax enable")
opt.background = "dark"

-- Mouse
opt.mouse = "a"
opt.clipboard = ""

-- Line numbers
opt.relativenumber = true

-- Search
opt.smartcase = true
opt.ignorecase = true
opt.incsearch = true
opt.hlsearch = true

-- Vim compatibility
opt.compatible = false
opt.hidden = true

-- Backup and swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Indentation
opt.autoindent = true
opt.expandtab = false -- Use tabs, not spaces
opt.paste = false

-- Command history
opt.history = 100

-- UI
opt.ruler = true
opt.showcmd = true
opt.cursorline = true

-- Completion
opt.completeopt:remove("preview")

-- Folding
opt.foldmethod = "marker"
opt.foldlevel = 0

-- Performance
opt.synmaxcol = 120

-- Misc
opt.inccommand = "nosplit"

-- Python provider
vim.g.loaded_python_provider = 1

-- Spell checking (disabled in VSCode)
if vim.g.vscode then
	opt.spell = false
else
	opt.spell = true
	opt.spelllang = "en_us"
end

-- CTags
opt.tags = "./tags;/"
