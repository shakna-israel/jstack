local jstack = require "jstack"

local jstack_env = {
	jstack.stdlib()
}

-- This scaffold will call the `draw` function from our `main.stk` file:
function love.draw()
	local caller = jstack.lookup(nil, jstack.make_symbol(nil, "draw"), jstack_env)
	local r = {jstack.eval(caller.content.value, jstack_env)}
	if not r[1] then
		if type(r[2]) == "table" then
			io.stderr:write(jstack.tostring(r[2]) .. "\n")
			love.quit()
		end
	end
end

function love.update()
	local caller = jstack.lookup(nil, jstack.make_symbol(nil, "update"), jstack_env)
	local r = {jstack.eval(caller.content.value, jstack_env)}
	if not r[1] then
		if type(r[2]) == "table" then
			io.stderr:write(jstack.tostring(r[2]) .. "\n")
			love.quit()
		end
	end
end

-- Load and call our `main.stk` file:
function love.load()
	local f = io.open("main.stk")
	local source = f:read("*all")
	f:close()
	local r = {jstack.eval(jstack.parse(source, "main.stk"), jstack_env)}
	if not r[1] then
		if type(r[2]) == "table" then
			io.stderr:write(jstack.tostring(r[2]) .. "\n")
			love.quit()
		end
	end
end
