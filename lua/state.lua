-- local log = vim.notify
local log = function(...) end

local M = {}

-- State for semicolon counter
M.semicolon_count = 0
M.window_timer = nil
M.semicolon_timer = nil

M.recursive_count = 0

M.increment_count = function(self)
	self.recursive_count = self.recursive_count + 1
	log("incrementing count to: " .. self.recursive_count)
end

M.reset_count = function(self)
	self.recursive_count = 0
	log("resetting count")
end

M.setup = function(self, opts)
	self.ns_id = vim.api.nvim_create_namespace("anchor.nvim")
	self.opts = opts
end

M.clear_key_callback = function(self)
	log("unsubscribing to on_key callback")
	vim.on_key(nil, self.ns_id)
end

M.trigger_anchor = function(self)
	if M.recursive_count == 0 then
		log("subscribing to on_key callback")
		vim.on_key(function(_, typed)
			log("input key: " .. typed)
			if typed ~= self.opt.trigger then
				self:clear_key_callback()
			end
			if typed ~= self.opt.jump and typed ~= self.opt.trigger then
				M:reset_count()
			end
		end, self.ns_id)
	end

	M:increment_count()
end

return M
