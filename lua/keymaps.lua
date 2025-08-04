local state = require("state")

local function bind_action(key, action, callback)
	vim.keymap.set("n", key, function()
		if state:is_anchor_active() or action == "activate" then
			callback()
		else
			vim.api.nvim_feedkeys(key, "n", false)
		end
	end)
end

local M = {}

M.keymaps = {}

M.setup = function(self, opts)
	self.keymaps = opts.keymaps or {}
end

M.bind_actions = function(self, callbacks)
	for action, key in pairs(self.keymaps) do
		local callback = callbacks[action]

		if type(key) == "table" then
			for _, k in ipairs(key) do
				bind_action(k, action, callback)
			end
		else
			bind_action(key, action, callback)
		end
	end
end

return M
