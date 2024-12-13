local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['cos^-1']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)

	-- TODO: actual behaviour
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("cos^-1: a"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("cos^-1: i10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value ~= stack[1].content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("cos^-1: f10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "float")
	assert(stack[1].content.value ~= stack[1].content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("cos^-1: i1"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 0)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("cos^-1: i0"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 1)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("cos^-1: f0.5"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "float")
	assert(stack[1].content.value == math.acos(0.5))
end
