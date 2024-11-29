local jstack = require "./jstack"
assert(jstack)

assert(jstack.to_lua)

-- jstack.to_lua(value)

-- TODO

do
	local s = jstack.make_nil(nil)
	assert(s)
	assert(jstack.to_lua(s) == nil)
end

do
	local s = jstack.make_symbol(nil, "true")
	assert(s)
	assert(jstack.to_lua(s) == true)
end

do
	local s = jstack.make_symbol(nil, "false")
	assert(s)
	assert(jstack.to_lua(s) == false)
end

do
	local s = jstack.make_symbol(nil, "nil")
	assert(s)
	assert(jstack.to_lua(s) == nil)
end

-- Lua doesn't have symbols.
-- Collapses into a string.
do
	local s = jstack.make_symbol(nil, "wat")
	assert(s)
	assert(jstack.to_lua(s) == "wat")
end

do
	local s = jstack.make_string(nil, "lol")
	assert(s)
	assert(jstack.to_lua(s) == "lol")
end

-- TODO: integer
-- TODO: float
-- TODO: foreign
-- TODO: interrupt
-- TODO: Error
-- TODO: Expression
