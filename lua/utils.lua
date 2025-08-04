local M = {}
local log_file = vim.fn.expand("~") .. "/anchor.log"

function M.assert(msg)
	vim.notify("ASSERT FAIL: " .. msg)
end

function M.log(msg)
	local f = io.open(log_file, "a")
	if not f then
		return
	end
	f:write(msg .. "\n")
	f:close()
end

return M
