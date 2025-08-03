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
	-- If there's a mapping, save it
	if existing and existing.lhs and existing.lhs ~= "" then
		return existing
	end
	-- Mark that no custom mapping exists (built-in keys like 'a' won't have mappings)
	return "NONE"
end

local function restore_keymap(mode, key, original)
	if original and original ~= "NONE" then
		-- Restore the saved mapping
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
		-- Delete our custom mapping to restore default behavior
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
	for action, keys in pairs(self.keymaps) do
		-- Convert single key to array for uniform handling
		local key_list = type(keys) == "table" and keys or { keys }

		for _, key in ipairs(key_list) do
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
				elseif action == "confirm" and self.callbacks.confirm then
					vim.keymap.set("n", key, self.callbacks.confirm, { noremap = true, silent = true })
				end
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
		restore_keymap("n", key, original)
	end

	self.original_keymaps = {}
end

return M
