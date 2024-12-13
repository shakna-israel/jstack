local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['divide']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("divide: a b"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("divide: i10 f21"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("divide: i10 i2"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 5)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("divide: i3 i2"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 1)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("divide: f10 f2"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "float")
	assert(stack[1].content.value == 5.0)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("divide: f3 f2"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "float")
	assert(stack[1].content.value == 1.5)
end
