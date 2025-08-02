local keymaps = require("keymaps")
local Buffer = require("buffers").Buffer

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
	for i, buffer in ipairs(buffers) do
		local line = buffer:render()

		-- Show arrow for the selected buffer (by index) OR the current buffer
		-- if i == self.current_index or buffer:is_current() then
		if i == self.current_index then
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
		open_search = function()
			self:hide()
			require("telescope").extensions.smart_open.smart_open({
				disable_devicons = true,
				initial_mode = "insert",
				cwd_only = true,
			})
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

	-- Re-render to update the current buffer indicator
	self:render(self.buffers)
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

	-- Re-render to update the current buffer indicator
	self:render(self.buffers)
end

M.toggle = function(self, lines)
	if self.win then
		self:hide()
	else
		self:show(lines)
	end
end

M.refresh = function(self)
	if not self.win then
		return
	end

	local buffer_tracker = require("buffer_tracker")
	local buffers = buffer_tracker.get_mru_buffers()

	-- If no buffers left, close the window
	if #buffers == 0 then
		self:hide()
		return
	end

	-- Update stored buffers
	self.buffers = buffers

	-- Find the current Neovim buffer in our list
	local current_bufnr = vim.api.nvim_get_current_buf()
	local found_current = false

	if vim.api.nvim_buf_is_valid(current_bufnr) then
		for i, buffer in ipairs(buffers) do
			if buffer.bufnr == current_bufnr then
				self.current_index = i
				found_current = true
				break
			end
		end
	end

	-- If current buffer was deleted or not in list, maintain index position
	if not found_current then
		-- Ensure index is within bounds
		if self.current_index > #buffers then
			self.current_index = #buffers
		elseif self.current_index < 1 then
			self.current_index = 1
		end
	end

	-- Re-render with updated buffer list
	self:render(buffers)
end

return M
