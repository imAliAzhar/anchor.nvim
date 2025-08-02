local window = require("window")
local state = require("state")
local buffer_tracker = require("buffer_tracker")

local M = {}

-- State for semicolon counter
local semicolon_count = 0
local semicolon_timer = nil
local window_timer = nil

local default_opts = {
	keymaps = {
		hide = { "j", "k" },
		focus_next = "<Leader>bn",
		focus_previous = "<Leader>bp",

		-- open_search = "i",
	},

	render_row = function(file_path)
		return file_path
	end,
}

-- Reset semicolon counter
local function reset_semicolon_count()
	semicolon_count = 0
	if semicolon_timer then
		vim.fn.timer_stop(semicolon_timer)
		semicolon_timer = nil
	end
	if window_timer then
		vim.fn.timer_stop(window_timer)
		window_timer = nil
	end
	-- Hide window if it's open
	if window.win then
		window:hide()
	end
end

-- Handle semicolon press
local function handle_semicolon()
	semicolon_count = semicolon_count + 1

	-- Reset window timer if it exists
	if window_timer then
		vim.fn.timer_stop(window_timer)
		window_timer = nil
	end

	-- Only start window timer on first semicolon
	if semicolon_count == 1 then
		window_timer = vim.fn.timer_start(200, function()
			-- Show window with MRU buffers
			local mru_buffers = buffer_tracker.get_mru_buffers()
			if #mru_buffers > 0 then
				window:show(mru_buffers)
				-- Set the initial selection based on semicolon count
				window.current_index = math.min(semicolon_count + 1, #mru_buffers)
				window:render(mru_buffers)
			end
		end)
	else
		-- Window is already shown or will be shown, update selection
		if window.win then
			local mru_buffers = buffer_tracker.get_mru_buffers()
			window.current_index = math.min(semicolon_count + 1, #mru_buffers)
			window:render(mru_buffers)
		end
	end

	-- No automatic reset timer - only reset on 'a' press or other actions
end

-- Handle 'a' press to switch buffers
local function handle_buffer_switch()
	if semicolon_count == 0 then
		-- If no semicolons were pressed, do nothing
		return
	end

	-- Hide window if it's open
	if window.win then
		window:hide()
	end

	-- Get buffers in MRU order
	local mru_buffers = buffer_tracker.get_mru_buffers()

	-- Switch to the buffer at position semicolon_count
	-- Note: semicolon_count = 1 means the most recent buffer (excluding current)
	-- Since MRU list includes current buffer at position 1, we use semicolon_count + 1
	local target_index = semicolon_count + 1

	if target_index <= #mru_buffers then
		local target_buffer = mru_buffers[target_index]
		if target_buffer then
			target_buffer:focus()
		end
	end

	-- Reset the counter after switching
	reset_semicolon_count()
end

M.setup = function(self, _opts)
	-- Deep merge options with defaults
	local opts = vim.tbl_deep_extend("force", default_opts, _opts or {})

	window:setup(opts)
	state:setup(opts)
	buffer_tracker.setup(window)

	-- Set up semicolon and 'a' keybindings
	vim.keymap.set("n", ";", handle_semicolon, { noremap = true, silent = true })
	vim.keymap.set("n", "a", handle_buffer_switch, { noremap = true, silent = true })

	-- Original keymaps for window display
	vim.keymap.set("n", "<Leader>bn", function()
		-- Get buffers in MRU order
		local mru_buffers = buffer_tracker.get_mru_buffers()
		window:show(mru_buffers)
	end, { noremap = true, silent = true })
end

M:setup()

return M
