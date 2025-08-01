local M = {}

---@type Buffer
---@diagnostic disable-next-line: unused-local
local Buffer = require("buffers").Buffer

---@class MRU
---@field items Buffer[] Array of Buffer objects ordered by recency (most recent first)
M.MRU = {}

---Create a new MRU instance
---@return MRU
function M.MRU:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.items = {}

	return o
end

---Add or update a buffer (moves to front if exists)
---@param item Buffer Buffer object to add (compares by bufnr)
function M.MRU:add(item)
	-- Remove item if it already exists
	for i, existing in ipairs(self.items) do
		-- For Buffer objects, compare by bufnr
		local is_same = false
		if type(existing) == "table" and type(item) == "table" and existing.bufnr and item.bufnr then
			is_same = existing.bufnr == item.bufnr
		else
			is_same = existing == item
		end

		if is_same then
			table.remove(self.items, i)
			break
		end
	end

	-- Add item to front
	table.insert(self.items, 1, item)
end

---Get all buffers in MRU order
---@return Buffer[]
function M.MRU:get_all()
	return vim.tbl_deep_extend("force", {}, self.items)
end

---Get the most recent buffer
---@return Buffer|nil
function M.MRU:get_most_recent()
	return self.items[1]
end

---Remove a buffer by buffer number
---@param bufnr number Buffer number to remove
---@return boolean True if buffer was removed
function M.MRU:remove(bufnr)
	for i, existing in ipairs(self.items) do
		if existing.bufnr == bufnr then
			table.remove(self.items, i)
			return true
		end
	end
	return false
end

---Clear all items
function M.MRU:clear()
	self.items = {}
end

---Get the number of items
---@return number
function M.MRU:size()
	return #self.items
end

return M
