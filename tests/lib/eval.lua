local jstack = require "./jstack"
assert(jstack)

assert(jstack.eval)

-- jstack.eval(tree, env, stack)

do
	assert(jstack.eval(nil, nil, nil))
end

do
	assert(jstack.eval(nil, {}, nil))
end

do
	assert(jstack.eval(nil, nil, {}))
end

do
	assert(jstack.eval({}, {}, {}))
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("$"), {}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "nil")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("$ thing"), {{thing = jstack.make_string(nil, "Hello")}}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "string")
	assert(stack[1].content.value == "Hello")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("thing$"), {{thing = jstack.make_string(nil, "Hello")}}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "string")
	assert(stack[1].content.value == "Hello")
end

-- Calling empty stack should error:
do
	local stack = {}
	local tree = jstack.parse("!")
	assert(#tree == 1)
	local r = {jstack.eval(tree, {}, stack)}
	assert(r[1] == false)
end

-- ? requires a function to call, or it fails.
do
	local stack = {}
	local tree = jstack.parse("? nil")
	assert(#tree == 2)
	local r = {jstack.eval(tree, {}, stack)}
	assert(r[1] == false)
end

-- If it doesn't fail, it casts to bool:
do
	local stack = {}
	assert(jstack.eval(jstack.parse("? thing$"), {{thing = jstack.make_builtin(
		"thing", "test", function(caller, env, stack)
			stack[#stack + 1] = jstack.make_string(caller, "Hello")
			return true
		end)}
	}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")
end

-- error<Critical> is instant failure, but requires something to raise it.
do
	local stack = {}
	local r = {jstack.eval(jstack.parse("? thing$"), {{thing = jstack.make_builtin(
		"thing", "test", function(caller, env, stack)
			return false
		end)}
	}, stack)}
	assert(r[1] == false)
end

do
	local stack = {}
	local r = {jstack.eval(jstack.parse("! thing$"), {{thing = jstack.make_builtin(
		"thing", "test", function(caller, env, stack)
			return false
		end)}
	}, stack)}
	assert(r[1] == false)
end
