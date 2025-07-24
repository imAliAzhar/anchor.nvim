local window = require("window")
local state = require("state")
local buffer_tracker = require("buffer_tracker")

local M = {}

local default_opts = {
	keymaps = {
		hide = ";",
		focus_next = "j",
		focus_previous = "k",
		open_search = "i",
	},

	render_row = function(file_path)
		return file_path
	end,
}

M.setup = function(self, _opts)
	-- Deep merge options with defaults
	local opts = vim.tbl_deep_extend("force", default_opts, _opts or {})

	window:setup(opts)
	state:setup(opts)
	buffer_tracker.setup(window)

	-- Keymaps
	vim.keymap.set("n", ";", function()
		-- Get buffers in MRU order
		local mru_buffers = buffer_tracker.get_mru_buffers()
		window:show(mru_buffers)
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
