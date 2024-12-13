local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local clear = jstack.stdlib()['clear']
	assert(clear)
	assert(clear.chunk == "stdlib")
	assert(clear.content.type == "builtin")
	assert(clear.help)
	assert(clear.content.value)

	local stack = {1, 2, 3}
	assert(#stack > 0)
	assert(clear.content.value(nil, {}, stack))
	assert(#stack == 0)
end

do
	local clear = jstack.stdlib()['clear']
	assert(clear)
	assert(clear.chunk == "stdlib")
	assert(clear.content.type == "builtin")
	assert(clear.help)
	assert(clear.content.value)

	local stack = {}
	assert(clear.content.value(nil, {}, stack))
	assert(#stack == 0)
end

do
	local clear = jstack.stdlib()['clear']
	assert(clear)
	assert(clear.chunk == "stdlib")
	assert(clear.content.type == "builtin")
	assert(clear.help)
	assert(clear.content.value)

	local stack = {}
	for i=1, 1000 do
		stack[#stack + 1] = jstack.make_symbol(nil, true)
	end
	assert(#stack > 0)

	assert(clear.content.value(nil, {}, stack))
	assert(#stack == 0)
end
