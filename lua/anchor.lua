local window = require("window")
local state = require("state")
local buffers = require("buffers")
local buffer_tracker = require("buffer_tracker")

local M = {}

local default_opts = {
	keymaps = {
		default = true,
		trigger = "<c-f>",
		jump = "a",
	},

	render_row = function(file_path)
		return file_path
	end,
}

M.setup = function(self, _opts)
	local opts = _opts or default_opts

	window:setup(opts)
	state:setup(opts)
	buffer_tracker:setup()

	-- Keymaps
	vim.keymap.set("n", ";", function()
		-- Get buffers in MRU order
		local mru_buffers = buffer_tracker.get_mru_buffers()
		window:toggle(mru_buffers)
	end, { noremap = true, silent = true })

	-- vim.keymap.set("n", opts.jump, function()
	-- 	M:select_tab()
	-- end, { noremap = true })
	--
	-- vim.keymap.set("n", opts.trigger, function()
	-- 	M:trigger_anchor()
	-- end, { noremap = true, silent = true, nowait = true })
end

M:setup()

return M
