local utils = require("utils")
local state = require("state")

local SHOW_WINDOW_TIMEOUT = 300

local M = {}

M.window_timer = nil

--- Setup
--- @param opts table
M.setup = function(self, opts)
	self.opts = opts

	local bg = opts.bg or "#1e1e2e"
	vim.api.nvim_set_hl(0, "AnchorNormal", { bg = bg, fg = opts.fg or "#cdd6f4" })
	vim.api.nvim_set_hl(0, "AnchorBorder", { fg = bg })
end

function M:setup_window_timer()
	self.window_timer = vim.fn.timer_start(SHOW_WINDOW_TIMEOUT, function()
		self:show()
	end)
end

M.render = function(self)
	if state.active == false then
		self:close_window()
		return
	end

	if not self.buf then
		return
	end

	local lines = {}
	for i, buffer in ipairs(state:get_buffers()) do
		local line = buffer:render()

		if i == state:get_current_index() then
			line = "▶ " .. line
		else
			line = "  " .. line
		end

		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines or {})
end

M.show = function(self)
	if self.buf then
		utils.assert("attemp to create a new buffer when one exists already")
	end

	self.buf = vim.api.nvim_create_buf(false, true)
	self:render()

	if self.win then
		utils.assert("attemp to create a new window when one exists already")
	end

	local win_opts = self:get_window_opts(#state:get_buffers())
	self.win = vim.api.nvim_open_win(self.buf, false, win_opts)

	vim.api.nvim_set_option_value("winhl", "Normal:AnchorNormal,FloatBorder:AnchorBorder", { win = self.win })
end

function M:close_window()
	if self.window_timer then
		vim.fn.timer_stop(self.window_timer)
	end

	if self.win and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_close(self.win, false)
	end
	self.win = nil

	if self.buf then
		vim.api.nvim_buf_delete(self.buf, { force = true })
	end
	self.buf = nil
end

function M:get_window_opts(lines_count)
	-- Get the total screen dimensions
	local total_lines = vim.o.lines -- Total screen lines (including command bar and status bar)
	local total_cols = vim.o.columns -- Total screen width

	-- Calculate the row and column for bottom-right positioning
	local win_height = 1 + lines_count -- Height of the floating window
	local win_width = 30 -- Width of the floating window

	-- Define the floating window options
	local win_opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		col = total_cols - win_width - 1,
		row = total_lines - 6,
		style = "minimal",
	}

	return win_opts
end

return M
