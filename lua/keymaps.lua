-- keymap.lua
local M = {}
M.keymaps = {}

function M:setup(opts)
	self.keymaps = opts.keymaps or {}
	self.saved = {} -- previously existing mappings
	self.temp_keys = {} -- every key we temporarily set
end

function M:bind_action(action, callback)
	local key = self.keymaps[action]
	local save = vim.fn.maparg(key, "n", false, true) -- dict=true
	if type(save) == "table" and next(save) ~= nil then
		table.insert(self.saved, save)
	end
	table.insert(self.temp_keys, key)
	vim.keymap.set("n", key, callback)
end

function M:restore()
	for _, key in ipairs(self.temp_keys) do
		if key ~= self.keymaps.activate then
			pcall(vim.keymap.del, "n", key)
		end
	end
	self.temp_keys = {}

	-- restore any mappings that existed before
	for _, d in ipairs(self.saved) do
		vim.fn.mapset(d)
	end
	self.saved = {}
end

return M
