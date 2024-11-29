local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_string)

do
	local s = jstack.make_string(nil, nil)
	assert(s)
	assert(s.content)
	assert(s.content.type == "string")
	assert(s.content.value == "")
end

do
	local s = jstack.make_string(nil, "hello world")
	assert(s)
	assert(s.content)
	assert(s.content.type == "string")
	assert(s.content.value == "hello world")
end
