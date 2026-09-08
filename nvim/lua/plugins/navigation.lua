-- Seamless split navigation with tmux and herdr.
--
-- <C-h/j/k/l> move between nvim windows first. At the edge they hand off to
-- whichever multiplexer is running: tmux via vim-tmux-navigator, herdr via
-- `herdr pane focus`. herdr sends the keypress here in the first place, see
-- bin/herdr-nav.

local directions = {
	{ key = "<C-h>", wincmd = "h", herdr = "left", tmux = "TmuxNavigateLeft" },
	{ key = "<C-j>", wincmd = "j", herdr = "down", tmux = "TmuxNavigateDown" },
	{ key = "<C-k>", wincmd = "k", herdr = "up", tmux = "TmuxNavigateUp" },
	{ key = "<C-l>", wincmd = "l", herdr = "right", tmux = "TmuxNavigateRight" },
	-- Terminals send <C-h> as backspace
	{ key = "<BS>", wincmd = "h", herdr = "left", tmux = "TmuxNavigateLeft" },
}

local function navigate(spec)
	return function()
		local from = vim.fn.winnr()
		vim.cmd("wincmd " .. spec.wincmd)

		-- Moved within nvim, nothing to hand off
		if vim.fn.winnr() ~= from then
			return
		end

		if vim.env.HERDR_ENV == "1" then
			vim.fn.jobstart({ "herdr", "pane", "focus", "--current", "--direction", spec.herdr }, { detach = true })
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
			-- Own the mappings so herdr gets the same treatment as tmux
			vim.g.tmux_navigator_no_mappings = 1

			for _, spec in ipairs(directions) do
				vim.keymap.set(
					"n",
					spec.key,
					navigate(spec),
					{ silent = true, desc = "Navigate " .. spec.herdr .. " (nvim/tmux/herdr)" }
				)
			end
		end,
	},
}
