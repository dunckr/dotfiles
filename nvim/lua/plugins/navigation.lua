-- Seamless split navigation with tmux and herdr-app.
--
-- <C-h/j/k/l> move between nvim windows first. At the edge they hand off to
-- whichever multiplexer is running: tmux via vim-tmux-navigator, herdr-app via
-- `herdr-app do pane.go`.

local directions = {
	{ key = "<C-h>", wincmd = "h", dir = "left", tmux = "TmuxNavigateLeft" },
	{ key = "<C-j>", wincmd = "j", dir = "down", tmux = "TmuxNavigateDown" },
	{ key = "<C-k>", wincmd = "k", dir = "up", tmux = "TmuxNavigateUp" },
	{ key = "<C-l>", wincmd = "l", dir = "right", tmux = "TmuxNavigateRight" },
	-- Terminals send <C-h> as backspace
	{ key = "<BS>", wincmd = "h", dir = "left", tmux = "TmuxNavigateLeft" },
}

local function navigate(spec)
	return function()
		local from = vim.fn.winnr()
		vim.cmd("wincmd " .. spec.wincmd)

		-- Moved within nvim, nothing to hand off
		if vim.fn.winnr() ~= from then
			return
		end

		if vim.env.HC_TERMINAL_ID then
			-- herdr-app has no vim-aware keys, so only the edge handoff applies
			vim.fn.jobstart({ "herdr-app", "do", "pane.go", "--direction", spec.dir }, { detach = true })
		elseif vim.env.TMUX then
			vim.cmd(spec.tmux)
		end
	end
end

return {
	-- Tmux navigation
	{
		"christoomey/vim-tmux-navigator",
		init = function()
			-- Own the mappings so herdr-app gets the same treatment as tmux
			vim.g.tmux_navigator_no_mappings = 1

			for _, spec in ipairs(directions) do
				vim.keymap.set(
					"n",
					spec.key,
					navigate(spec),
					{ silent = true, desc = "Navigate " .. spec.dir .. " (nvim/tmux/herdr-app)" }
				)
			end
		end,
	},
}
