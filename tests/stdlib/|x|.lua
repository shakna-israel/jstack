local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['|x|']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("|x|: a"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("|x|: i10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 10)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("|x|: i-10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 10)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("|x|: f10.4"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "float")
	assert(stack[1].content.value == 10.4)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("|x|: f-10.4"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "float")
	assert(stack[1].content.value == 10.4)
end
