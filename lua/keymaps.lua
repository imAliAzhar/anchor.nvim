local M = {}

M.callbacks = {}
M.original_keymaps = {}
M.active = false
M.keymaps = {}

M.setup = function(self, opts)
	self.opts = opts or {}
	self.keymaps = opts.keymaps or {}
end

local function save_keymap(mode, key)
	local existing = vim.fn.maparg(key, mode, false, true)
	if existing and existing.lhs then
		return existing
	end
	return nil
end

local function restore_keymap(mode, key, original)
	if original then
		local opts = {
			noremap = original.noremap == 1,
			silent = original.silent == 1,
			expr = original.expr == 1,
			nowait = original.nowait == 1,
		}
		if original.callback then
			opts.callback = original.callback
		end
		vim.keymap.set(mode, key, original.rhs or original.callback, opts)
	else
		pcall(vim.keymap.del, mode, key)
	end
end

M.activate = function(self, callbacks)
	if self.active then
		return
	end

	self.active = true
	self.callbacks = callbacks or {}

	-- Set up keymaps based on configuration
	for action, key in pairs(self.keymaps) do
		if key and key ~= "" then
			-- Save original keymap
			self.original_keymaps[key] = save_keymap("n", key)

			-- Set custom keymap based on action
			if action == "hide" and self.callbacks.hide then
				vim.keymap.set("n", key, self.callbacks.hide, { noremap = true, silent = true })
			elseif action == "focus_next" and self.callbacks.focus_next then
				vim.keymap.set("n", key, self.callbacks.focus_next, { noremap = true, silent = true })
			elseif action == "focus_previous" and self.callbacks.focus_previous then
				vim.keymap.set("n", key, self.callbacks.focus_previous, { noremap = true, silent = true })
			elseif action == "open_search" and self.callbacks.open_search then
				vim.keymap.set("n", key, self.callbacks.open_search, { noremap = true, silent = true })
			end
		end
	end
end

M.deactivate = function(self)
	if not self.active then
		return
	end

	self.active = false

	-- Restore all original keymaps
	for key, original in pairs(self.original_keymaps) do
		if original ~= nil then
			restore_keymap("n", key, original)
		else
			pcall(vim.keymap.del, "n", key)
		end
	end

	self.original_keymaps = {}
end

return M
