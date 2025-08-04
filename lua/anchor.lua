local state = require("state")
local window = require("window")
local keymaps = require("keymaps")
local buffer_tracker = require("buffer_tracker")

local M = {}

local default_opts = {
	keymaps = {
		activate = ";",
		hide = { "<esc>", "q" },
		focus_next = "j",
		focus_previous = "k",
		confirm = "a",
	},
}

local function activate_or_next()
	if not state:is_anchor_active() then
		state:setup_state()
		window:setup_window_timer()
	else
		state:increment_current_index()
	end
end

local function confirm()
	state:select_current_buffer()
	window:close_window()
end

M.setup = function(_, _opts)
	local opts = vim.tbl_deep_extend("force", default_opts, _opts or {})

	window:setup(opts)
	state:setup(opts)
	keymaps:setup(opts)
	buffer_tracker.setup()

	keymaps:bind_actions({
		activate = function()
			activate_or_next()
		end,
		focus_next = function()
			state:increment_current_index()
			window:render()
		end,
		focus_previous = function()
			state:decrement_current_index()
			window:render()
		end,
		confirm = function()
			confirm()
		end,
		hide = function()
			window:close_window()
			state:deactivate()
		end,
	})
end

M:setup()

return M
