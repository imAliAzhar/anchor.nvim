local state = require("state")
local window = require("window")
local buffer_tracker = require("buffer_tracker")

local M = {}

local default_opts = {
	keymaps = {
		hide = "q",
		focus_next = { "j", ";" },
		focus_previous = "k",
		confirm = "a",
	},
}

-- Handle semicolon press
local function handle_semicolon()
	-- If window is already open, semicolon acts as focus_next
	if window.win then
		window:focus_next()
		return
	end

	-- Window is not open, continue with counter logic
	state.semicolon_count = state.semicolon_count + 1

	-- Always set/reset the window timer on every semicolon press
	if state.window_timer then
		vim.fn.timer_stop(state.window_timer)
	end

	state.window_timer = vim.fn.timer_start(200, function()
		-- Show window with MRU buffers
		local mru_buffers = buffer_tracker.get_mru_buffers()
		if #mru_buffers > 0 then
			window:show(mru_buffers)
			-- Set the initial selection based on semicolon count
			window.current_index = math.min(state.semicolon_count + 1, #mru_buffers)
			window:render(mru_buffers)
		end
		state.window_timer = nil
	end)

	-- No automatic reset timer - only reset on 'a' press or other actions
end

M.setup = function(_, _opts)
	-- Deep merge options with defaults
	local opts = vim.tbl_deep_extend("force", default_opts, _opts or {})

	window:setup(opts)
	state:setup(opts)
	buffer_tracker.setup(window)

	-- Set up semicolon and 'a' keybindings
	vim.keymap.set("n", ";", handle_semicolon, { noremap = true, silent = true })
	
	-- Set up 'a' for quick buffer switching (only active when semicolon was pressed)
	vim.keymap.set("n", opts.keymaps.confirm, function()
		-- Only handle if semicolon was pressed and window is not yet open
		if state.semicolon_count > 0 and not window.win then
			window:handle_buffer_switch()
			window:reset_semicolon_count()
		else
			-- Otherwise, execute the default 'a' behavior
			vim.api.nvim_feedkeys('a', 'n', false)
		end
	end, { noremap = true, silent = true })
end

M:setup()

return M
