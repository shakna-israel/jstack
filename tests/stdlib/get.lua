local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['get']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("get: a"), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "nil")
end

do
	local stack = {}
	local stdlib = jstack.stdlib()
	assert(jstack.eval(jstack.parse("get: get"), {stdlib}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "builtin")
	assert(stack[1].content.value == stdlib['get'].content.value)
end

do
	local stack = {}
	local stdlib = jstack.stdlib()
	local prog = [=[
	let: a i21
	{
		let: a i17
		get: a
	}
	!
	get: a
	]=]
	assert(jstack.eval(jstack.parse(prog), {stdlib}, stack))
	assert(#stack == 2)
	assert(stack[1].content.type == "integer")
	assert(stack[1].content.value == 17)
	assert(stack[2].content.type == "integer")
	assert(stack[2].content.value == 21)
end
