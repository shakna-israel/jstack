local jstack = require "jstack"

local jstack_env = {
	jstack.stdlib()
}

-- Load and call our `main.stk` file:
function love.load()
	local f = io.open("main.stk")
	local source = f:read("*all")
	f:close()
	local r = {jstack.eval(jstack.parse(source, "main.stk"), jstack_env)}
	if not r[1] then
		if type(r[2]) == "table" then
			io.stderr:write(jstack.tostring(r[2]) .. "\n")
			love.event.push("quit", 1)
		end
	end
end
