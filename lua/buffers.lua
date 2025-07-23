local M = {}

---@class Buffer
---@field bufnr number Buffer number
---@field path string Full file path
---@field name string File name shown in buffer
M.Buffer = {}

---Create a new Buffer instance
---@param bufnr number
---@return Buffer
function M.Buffer:new(bufnr)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.bufnr = bufnr
	o.path = vim.api.nvim_buf_get_name(bufnr)
	o.name = M.get_name(o.path)

	return o
end

---Render the buffer name
---@return string
function M.Buffer:render()
	return self.name
end

---Check if this buffer is currently focused
---@return boolean
function M.Buffer:is_current()
	return self.bufnr == vim.api.nvim_get_current_buf()
end

M.get_buffers = function()
	local bufnrs = vim.tbl_filter(M.is_valid_and_listed, vim.api.nvim_list_bufs())

	if not next(bufnrs) then
		vim.notify("No buffers found with the provided options")
		return
	end

	local buffers = {}

	for _, bufnr in ipairs(bufnrs) do
		local buffer = M.Buffer:new(bufnr)
		table.insert(buffers, buffer)
	end

	return buffers
end

---Check if buffer is valid and listed
---@param bufnr number Buffer number to check
---@return boolean
M.is_valid_and_listed = function(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr) and vim.fn.buflisted(bufnr) == 1
end

---Get the display name for a buffer
---@param path string The buffer's file path
---@return string
M.get_name = function(path)
	if path == "" then
		return "[No Name]"
	else
		return vim.fn.fnamemodify(path, ":t")
	end
end

return M
