local keymaps = require("keymaps")

local M = {}

--- Setup
--- @param opts table
M.setup = function(self, opts)
	self.opts = opts

	local bg = opts.bg or "#1e1e2e"
	vim.api.nvim_set_hl(0, "AnchorNormal", { bg = bg, fg = opts.fg or "#cdd6f4" })
	vim.api.nvim_set_hl(0, "AnchorBorder", { fg = bg })

	keymaps:setup(opts)
end

M.render = function(self, buffers)
	local lines = {}
	for _, buffer in ipairs(buffers) do
		local line = buffer:render()

		if buffer:is_current() then
			line = "▶ " .. line
		else
			line = "  " .. line
		end

		table.insert(lines, line)
	end
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines or {})
end

M.show = function(self, buffers)
	if self.win then
		return
	end

	self.buf = vim.api.nvim_create_buf(false, true)

	self:render(buffers)

	-- Get the total screen dimensions
	local total_lines = vim.o.lines -- Total screen lines (including command bar and status bar)
	local total_cols = vim.o.columns -- Total screen width

	-- Calculate the row and column for bottom-right positioning
	local win_height = 1 + #buffers -- Height of the floating window
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

	-- Open the floating window
	self.win = vim.api.nvim_open_win(self.buf, false, win_opts)

	-- Apply custom highlights to the window
	vim.api.nvim_set_option_value("winhl", "Normal:AnchorNormal,FloatBorder:AnchorBorder", { win = self.win })

	-- Activate custom keymaps with callbacks
	keymaps:activate({
		hide = function()
			self:hide()
		end,
		focus_next = function()
			-- TODO: Implement focus_next functionality
		end,
	})
end

M.hide = function(self)
	vim.api.nvim_win_close(self.win, false)
	self.win = nil

	keymaps:deactivate()
end

M.toggle = function(self, lines)
	if self.win then
		self:hide()
	else
		self:show(lines)
	end
end

return M
