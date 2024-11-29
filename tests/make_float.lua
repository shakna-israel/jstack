local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_float)

do
	local s = jstack.make_float(nil, nil)
	assert(s)
	assert(s.content)
	assert(s.content.type == "float")
	assert(s.content.value == 0.0)
end

do
	local s = jstack.make_float(nil, 10)
	assert(s)
	assert(s.content)
	assert(s.content.type == "float")
	assert(s.content.value == 10.0)
end

do
	local s = jstack.make_float(nil, 10.3)
	assert(s)
	assert(s.content)
	assert(s.content.type == "float")
	assert(s.content.value == 10.3)
end
