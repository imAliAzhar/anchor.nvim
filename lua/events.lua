local Emitter = {}
Emitter.__index = Emitter

function Emitter.new()
	local self = setmetatable({}, Emitter)
	self.listeners = {}
	return self
end

function Emitter:on(event, callback)
	if not self.listeners[event] then
		self.listeners[event] = {}
	end

	table.insert(self.listeners[event], callback)

	return function()
		self:off(event, callback)
	end
end

function Emitter:off(event, callback)
	if not self.listeners[event] then
		return
	end

	for i, v in ipairs(self.listeners[event]) do
		if v == callback then
			table.remove(self.listeners[event], i)
			return
		end
	end
end

function Emitter:send(event)
	if not self.listeners[event] then
		return
	end

	for _, v in ipairs(self.listeners[event]) do
		v()
	end
end

local M = {}
M.ANCHOR = Emitter.new()

return M
