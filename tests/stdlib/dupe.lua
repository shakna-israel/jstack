local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['dupe']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("dupe!"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "nil")
end

do
	local x = jstack.make_string(nil, "Hello")
	local stack = {x}
	assert(jstack.eval(jstack.parse("dupe!"), {jstack.stdlib()}, stack))
	assert(#stack == 2)
	-- Dupe makes a `reference` to the same table:
	assert(stack[1] == stack[2])
	assert(stack[1] == x)
end
