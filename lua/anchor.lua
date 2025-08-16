local state = require("state")
local window = require("window")
local keymaps = require("keymaps")
local buffer_tracker = require("buffer_tracker")

local M = {}

local default_opts = {
	keymaps = {
		activate = ";",
		hide = "<esc>",
		focus_next = "j",
		focus_previous = "k",
		confirm = "a",
	},
}

local function confirm()
	state:select_current_buffer()
	window:close_window()
	keymaps:restore()
end

local focus_next = function()
	state:increment_current_index()
	window:render()
end
local focus_previous = function()
	state:decrement_current_index()
	window:render()
end
local hide = function()
	window:close_window()
	state:deactivate()
	keymaps:restore()
end

local function activate_or_next()
	if not state:is_anchor_active() then
		keymaps:bind_action("focus_next", focus_next)
		keymaps:bind_action("focus_previous", focus_previous)
		keymaps:bind_action("confirm", confirm)
		keymaps:bind_action("hide", hide)

		state:setup_state()
		window:setup_window_timer()
	else
		state:increment_current_index()
		window:render()
	end
end

M.setup = function(_, _opts)
	local opts = vim.tbl_deep_extend("force", default_opts, _opts or {})

	window:setup(opts)
	state:setup(opts)
	keymaps:setup(opts)
	buffer_tracker.setup()

	keymaps:bind_action("activate", activate_or_next)
end

M:setup()

return M
