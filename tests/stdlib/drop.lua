local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['drop']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("drop: a"), {jstack.stdlib()}, stack))
	assert(#stack == 0)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("drop: a i10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 10)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("drop: drop: a i10"), {jstack.stdlib()}, stack))
	assert(#stack == 0)
end
