local jstack = require "./jstack"
assert(jstack)

assert(jstack.exec)

-- Empty call is an error<Critical>:
do
	local r = {jstack.exec()}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end

do
	local r = {jstack.exec(nil, nil, {})}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end

do
	local r = {jstack.exec(nil, {}, {})}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end

-- A non-callable is a type error:
do
	local stack = {jstack.make_string(nil, "Hello")}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == true)
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

-- Can't call a nil:
do
	local stack = {jstack.make_symbol(nil, "Hello")}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end

do
	local stack = {jstack.make_symbol(nil, "nil")}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end

do
	local stack = {jstack.make_symbol(nil, "false")}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end

-- builtin calls:
do
	local stack = {jstack.make_builtin("thing", "test", function(caller, env, stack)
		stack[#stack + 1] = jstack.make_string(caller, "Hello")
		return true
	end)}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == true)
	assert(stack[1].content.type == "string")
	assert(stack[1].content.value == "Hello")
end

do
	local stack = {jstack.make_builtin("thing", "test", function(caller, env, stack)
		stack[#stack + 1] = jstack.make_string(caller, "Hello")
		return false
	end)}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end

-- expressions can be called:
do
	local stack = {jstack.make_expression(nil)}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == true)
end

do
	local stack = {jstack.parse("{false}")[1]}
	local r = {jstack.exec(nil, nil, stack)}
	assert(r[1] == true)
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "false")
end

-- looked up symbol:

-- Non-callable is an error<Type>:
do
	local stack = {jstack.make_symbol(nil, "thing")}
	local env = {{thing = jstack.make_string(nil, "Hello!")}}
	local r = {jstack.exec(nil, env, stack)}
	assert(r[1] == true)
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {jstack.make_symbol(nil, "thing")}
	local env = {{thing = jstack.make_builtin("thing", "test", function(caller, env, stack)
		stack[#stack + 1] = jstack.make_string(caller, "Hello")
		return true
	end)}}
	local r = {jstack.exec({}, env, stack)}
	assert(r[1] == true)
	assert(#stack == 1)
	assert(stack[1].content.type == "string")
	assert(stack[1].content.value == "Hello")
end

do
	local stack = {jstack.make_symbol(nil, "thing")}
	local env = {{thing = jstack.make_builtin("thing", "test", function(caller, env, stack)
		return false
	end)}}
	local r = {jstack.exec({}, env, stack)}
	assert(r[1] == false)
	assert(r[2].content.type == "error")
	assert(r[2].content.value == "Critical")
end
