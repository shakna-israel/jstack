local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_integer)

do
	local s = jstack.make_integer(nil, nil)
	assert(s)
	assert(s.content)
	assert(s.content.type == "integer")
	assert(s.content.value == 0)
end

do
	local s = jstack.make_integer(nil, 10.3)
	assert(s)
	assert(s.content)
	assert(s.content.type == "integer")
	assert(s.content.value == 10)
end

do
	local s = jstack.make_integer(nil, -10.3)
	assert(s)
	assert(s.content)
	assert(s.content.type == "integer")
	assert(s.content.value == -11)
end
