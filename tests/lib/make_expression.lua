local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_expression)

do
	local o = jstack.make_expression()
	assert(o)
	assert(o.content)
	assert(o.content.type == "expression")
	assert(type(o.content.value) == "table")
	assert(#o.content.value == 0)
end
