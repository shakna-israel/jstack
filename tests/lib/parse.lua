local jstack = require "./jstack"
assert(jstack)

assert(jstack.parse)
do
	-- Assert runs with no args:
	assert(jstack.parse())
end
do
	-- Empty tree, all defaults:
	local r = {jstack.parse()}
	assert(r[1])
	assert(type(r[1]) == "table")
	assert(#r[1] == 0)
end

do
	-- simple tree, all defaults:
	local r = {jstack.parse("hello")}
	assert(r[1])
	assert(type(r[1]) == "table")
	assert(#r[1] == 1)

	local value = r[1][1]
	assert(type(value) == "table")
	assert(value.chunk == "<unknown>") -- Default chunkname.
	assert(value.line == 1)
	-- Char measured from *end* of token:
	assert(value.char == 5)

	-- Has a set of type values:
	assert(value.content)
	assert(value.content.type == "symbol")
	assert(value.content.value == "hello")
	assert(value.content.raw == "hello")
end

-- TODO
-- TODO: String escaping...
-- TODO: Nested expressions...
-- TODO: Empty string
-- TODO: Empty expression
