local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_error)

do
	local s = jstack.make_error(nil, nil, nil)
	assert(s)
	assert(s.content)
	assert(s.content.type == "error")
	assert(s.content.value == nil)
	assert(s.content.extra == nil)
end

do
	local s = jstack.make_error(nil, "Type", nil)
	assert(s)
	assert(s.content)
	assert(s.content.type == "error")
	assert(s.content.value == "Type")
	assert(s.content.extra == nil)
end

do
	local s = jstack.make_error(nil, "Type", "LOL")
	assert(s)
	assert(s.content)
	assert(s.content.type == "error")
	assert(s.content.value == "Type")
	assert(s.content.extra == "LOL")
end
