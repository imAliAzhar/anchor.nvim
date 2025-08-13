local utils = require("utils")
local buffer_tracker = require("buffer_tracker")

local M = {}

M.active = false

-- State for semicolon counter
M.semicolon_count = 0
M.window_timer = nil
M.semicolon_timer = nil
-- State for tracking buffers
M.buffers = {}
M.current_index = 1

function M:setup(opts)
	self.opts = opts
end

function M:setup_state()
	utils.log("Setting up state...")
	self.active = true

	self.buffers = buffer_tracker.get_mru_buffers()

	if #self.buffers < 1 then
		utils.assert("number of buffers less than 1")
	end

	self.current_index = math.min(2, #self.buffers) -- focus the next one in list
end

function M:get_buffers()
	return self.buffers
end

function M:get_current_index()
	return self.current_index
end

function M:is_anchor_active()
	return self.active
end

function M:increment_current_index()
	if not self.buffers or #self.buffers == 0 then
		-- utils.assert("no next buffer to focus" )
		utils.assert("no next buffer to focus: " .. #self.buffers)
		return
	end

	-- Move to next buffer (with wrap-around)
	self.current_index = self.current_index % #self.buffers + 1
end

function M:decrement_current_index()
	if not self.buffers or #self.buffers == 0 then
		utils.assert("no previous buffer to focus")
		return
	end

	-- Move to previous buffer (with wrap-around)
	self.current_index = self.current_index - 1
	if self.current_index < 1 then
		self.current_index = #self.buffers
	end
end

function M:deactivate()
	self.active = false
end

function M:select_current_buffer()
	local selected_buffer = self.buffers[self.current_index]

	if not selected_buffer then
		utils.assert("current_index points to invalid item in buffer list")
	end

	selected_buffer:focus()
	self:deactivate()
end

function M:delete_current_buffer()
	local buffer = self.buffers[self.current_index]

	if not buffer or not buffer.bufnr then
		return
	end

	for i, b in ipairs(self.buffers) do
		if b == buffer then
			table.remove(self.buffers, i)
		end
	end

	buffer_tracker.remove_buffer(buffer.bufnr)
	vim.api.nvim_buf_delete(buffer.bufnr, { force = true })
end

return M
