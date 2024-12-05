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
	assert(clear.content.value(nil, {}, stack))
	assert(#stack == 0)
end
