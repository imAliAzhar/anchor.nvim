local buffers_module = require("buffers")
local Buffer = buffers_module.Buffer

local M = {}
local mru = require("mru")

---@type MRU
M.buffer_mru = mru.MRU:new()

---Track a buffer in MRU order
---@param buffer Buffer Buffer object to track
M.track_buffer = function(buffer)
	M.buffer_mru:add(buffer)
end

---Get all buffers in MRU order
---@return Buffer[] Array of valid Buffer objects
M.get_mru_buffers = function()
	local mru_buffers = M.buffer_mru:get_all()
	local valid_buffers = {}

	for _, buffer in ipairs(mru_buffers) do
		if buffers_module.is_valid_and_listed(buffer.bufnr) then
			-- Refresh buffer info in case path/name changed
			buffer.path = vim.api.nvim_buf_get_name(buffer.bufnr)
			buffer.name = buffers_module.get_name(buffer.path)
			table.insert(valid_buffers, buffer)
		else
			M.buffer_mru:remove(buffer)
		end
	end

	return valid_buffers
end

---Track all existing buffers
local function track_all_existing_buffers()
	local all_buffers = buffers_module.get_buffers()
	local current_buffer = nil

	if all_buffers then
		-- Track all buffers except the current one
		local current_bufnr = vim.api.nvim_get_current_buf()
		for _, buffer in ipairs(all_buffers) do
			if buffer.bufnr ~= current_bufnr then
				M.track_buffer(buffer)
			else
				current_buffer = buffer
			end
		end

		-- Track current buffer last so it's most recent
		if current_buffer then
			M.track_buffer(current_buffer)
		end
	end
end

M.setup = function()
	local group = vim.api.nvim_create_augroup("AnchorBufferTracker", { clear = true })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function(args)
			local buffer = Buffer:new(args.buf)
			M.track_buffer(buffer)
		end,
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(args)
			local buffer = Buffer:new(args.buf)
			M.buffer_mru:remove(buffer)
		end,
	})

	-- Track all existing buffers on startup
	track_all_existing_buffers()

	-- Also track buffers after session loads
	vim.api.nvim_create_autocmd("SessionLoadPost", {
		group = group,
		callback = function()
			track_all_existing_buffers()
		end,
	})
end

return M
