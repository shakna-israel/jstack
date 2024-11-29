local jstack = require "./jstack"
assert(jstack)

assert(jstack.lookup)

do
	local e = {jstack.stdlib()}
	assert(e)
	assert(e[1])
	assert(e[1].print)

	local target = jstack.make_string(nil, "print")
	local s = jstack.lookup(nil, target, e)
	assert(s)
	assert(s == e[1].print)
end

do
	local e = {jstack.stdlib()}
	for i=1, 100 do
		e[#e + 1] = {}
	end
	assert(e)
	assert(e[1])
	assert(e[1].print)

	local target = jstack.make_string(nil, "print")
	local s = jstack.lookup(nil, target, e)
	assert(s)
	assert(s == e[1].print)
end

do
	local e = {jstack.stdlib()}
	for i=1, 100 do
		e[#e + 1] = {}
	end

	local functor = function(...) end

	e[#e]['print'] = jstack.from_lua(nil, functor)

	assert(e)
	assert(e[1])
	assert(e[1].print)

	local target = jstack.make_string(nil, "print")
	local s = jstack.lookup(nil, target, e)
	assert(s)
	assert(s.content.type == "builtin")

	local v = jstack.lookup(nil, target, e)
	assert(v)
	assert(v.content.type == "builtin")
	assert(v == s)

	e[#e + 1] = jstack.stdlib()

	local v = jstack.lookup(nil, target, e)
	assert(v)
	assert(v ~= s)
end
