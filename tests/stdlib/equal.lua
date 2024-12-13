local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['equal']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	-- Empty stack turns into two nils:
	local stack = {}
	assert(jstack.eval(jstack.parse("equal:"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("equal: a \"a\""), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "false")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("equal: a a"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("equal: i10 i10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("equal: i10 f10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "false")
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("equal: f10 f10"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")
end

-- TODO: Expression comparison...
