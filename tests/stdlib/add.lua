local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['add']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("add: a b"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("add: i10 f10.1"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("add: i10 i-3"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 7)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("add: f10 f-3.1"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "float")
	assert(stack[1].content.value == 6.9)
end
