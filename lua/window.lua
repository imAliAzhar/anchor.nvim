local keymaps = require("keymaps")

local M = {}

-- State for tracking buffers
M.buffers = {}
M.current_index = 2

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

	-- Store buffers and find current buffer index
	self.buffers = buffers
	self.current_index = 1
	for i, buffer in ipairs(buffers) do
		if buffer:is_current() then
			self.current_index = i
			break
		end
	end

	self.buf = vim.api.nvim_create_buf(false, true)

	self:render(buffers)

	-- Automatically focus the second buffer if available
	if #buffers >= 2 then
		local second_buffer = buffers[2]
		if second_buffer then
			second_buffer:focus()
			self.current_index = 2
			-- Re-render to update the indicator
			self:render(buffers)
		end
	end

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

	-- Create autocmd to close window on insert mode
	self.autocmd_group = vim.api.nvim_create_augroup("AnchorWindow", { clear = true })
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = self.autocmd_group,
		callback = function()
			if self.win then
				self:hide()
			end
		end,
	})

	-- Activate custom keymaps with callbacks
	keymaps:activate({
		focus_next = function()
			self:focus_next()
		end,
		hide = function()
			self:hide()
		end,
		focus_previous = function()
			self:focus_previous()
		end,
	})
end

M.hide = function(self)
	vim.api.nvim_win_close(self.win, false)
	self.win = nil

	-- Clean up autocmd group
	if self.autocmd_group then
		vim.api.nvim_del_augroup_by_id(self.autocmd_group)
		self.autocmd_group = nil
	end

	keymaps:deactivate()
end

M.focus_next = function(self)
	if not self.buffers or #self.buffers == 0 then
		return
	end

	-- Move to next buffer (with wrap-around)
	self.current_index = self.current_index % #self.buffers + 1

	-- Switch to the next buffer
	local next_buffer = self.buffers[self.current_index]
	if next_buffer then
		next_buffer:focus()

		-- Re-render to update the current buffer indicator
		self:render(self.buffers)
	end
end

M.focus_previous = function(self)
	if not self.buffers or #self.buffers == 0 then
		return
	end

	-- Move to previous buffer (with wrap-around)
	self.current_index = self.current_index - 1
	if self.current_index < 1 then
		self.current_index = #self.buffers
	end

	-- Switch to the previous buffer
	local prev_buffer = self.buffers[self.current_index]
	if prev_buffer then
		prev_buffer:focus()

		-- Re-render to update the current buffer indicator
		self:render(self.buffers)
	end
end

M.toggle = function(self, lines)
	if self.win then
		self:hide()
	else
		self:show(lines)
	end
end

return M
