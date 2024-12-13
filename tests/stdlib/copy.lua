local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['copy']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {jstack.make_symbol(nil, true)}
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")
	assert(jstack.eval(jstack.parse("copy!"), {jstack.stdlib()}, stack))
	assert(#stack == 2)
	assert(stack[1] ~= stack[2])
	assert(stack[2].content.type == "symbol")
	assert(stack[2].content.value == "true")
end

do
	local stack = {}
	assert(#stack == 0)
	assert(jstack.eval(jstack.parse("copy!"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "nil")
end
