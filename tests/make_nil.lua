local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_nil)

do
	local s = jstack.make_nil(nil)
	assert(s)
	assert(s.content)
	assert(s.content.type == "symbol")
	assert(s.content.value == "nil")
end
