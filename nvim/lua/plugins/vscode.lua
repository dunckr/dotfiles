-- VSCode-specific plugin configuration
-- Keymaps are already defined in lua/config/keymaps.lua
-- This file returns an empty table since VSCode Neovim integration
-- is handled by the extension itself

if not vim.g.vscode then
	return {}
end

return {}
