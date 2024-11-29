local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_symbol)

do
	local s = jstack.make_symbol(nil, nil)
	assert(s)
	assert(s.content)
	assert(s.content.type == "symbol")
	assert(s.content.value == "nil")
end

do
	local s = jstack.make_symbol(nil, true)
	assert(s)
	assert(s.content)
	assert(s.content.type == "symbol")
	assert(s.content.value == "true")
end

do
	local s = jstack.make_symbol(nil, false)
	assert(s)
	assert(s.content)
	assert(s.content.type == "symbol")
	assert(s.content.value == "false")
end

do
	local s = jstack.make_symbol(nil, "Thing")
	assert(s)
	assert(s.content)
	assert(s.content.type == "symbol")
	assert(s.content.value == "Thing")
end
