local jstack = require "./jstack"
assert(jstack)

assert(jstack.parsevalue)
do
	assert(jstack.parsevalue())
end
do
	-- Default, empty token.
	-- Note: Should not happen when using `jstack.parse`.
	-- Just for library helpfulness.
	local v = jstack.parsevalue()
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "symbol")

	assert(v.value)
	assert(v.value == "")
	
	assert(v.raw)
	assert(v.raw == "")
end

do
	local v = jstack.parsevalue("true")
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "symbol")

	assert(v.value)
	assert(v.value == "true")
	
	assert(v.raw)
	assert(v.raw == "true")
end

do
	local v = jstack.parsevalue("false")
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "symbol")

	assert(v.value)
	assert(v.value == "false")
	
	assert(v.raw)
	assert(v.raw == "false")
end

do
	local v = jstack.parsevalue("nil")
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "symbol")

	assert(v.value)
	assert(v.value == "nil")
	
	assert(v.raw)
	assert(v.raw == "nil")
end

do
	local v = jstack.parsevalue("asymbol")
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "symbol")

	assert(v.value)
	assert(v.value == "asymbol")
	
	assert(v.raw)
	assert(v.raw == "asymbol")
end
do
	local v = jstack.parsevalue("`a symbol`")
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "symbol")

	assert(v.value)
	assert(v.value == "a symbol")
	
	assert(v.raw)
	assert(v.raw == "`a symbol`")
end

do
	local v = jstack.parsevalue("'some string'")
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "string")

	assert(v.value)
	assert(v.value == "some string")
	
	assert(v.raw)
	assert(v.raw == "'some string'")
end
do
	local v = jstack.parsevalue("[some string]")
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "string")

	assert(v.value)
	assert(v.value == "some string")
	
	assert(v.raw)
	assert(v.raw == "[some string]")
end
do
	local v = jstack.parsevalue('"some string"')
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "string")

	assert(v.value)
	assert(v.value == "some string")
	
	assert(v.raw)
	assert(v.raw == '"some string"')
end

do
	-- NOTE: Escaping is handled by jstack.parse, not jstack.parsevalue.
	local v = jstack.parsevalue('"some\nstring"')
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "string")

	assert(v.value)
	assert(v.value == "some\nstring")
	
	assert(v.raw)
	assert(v.raw == '"some\nstring"')
end

do
	for i=-1000, 1000 do
		do
			local token = string.format("i%d", i)

			local v = jstack.parsevalue(token)
			assert(v)
			assert(type(v) == "table")
			
			assert(v.type)
			assert(v.type == "integer")

			assert(v.value)
			assert(v.value == i)
			
			assert(v.raw)
			assert(v.raw == token)
		end
	end
end

do
	for i=-1000, 1000 do
		for f=0, 1000 do
			do
				local num = tonumber(string.format("%d.%d", i, f))
				local token = "f" .. tostring(num)

				local v = jstack.parsevalue(token)
				assert(v)
				assert(type(v) == "table")
				
				assert(v.type)
				assert(v.type == "float")

				assert(v.value)
				assert(v.value == num)
				
				assert(v.raw)
				assert(v.raw == token)
			end
		end
	end
end

do
	-- NOTE: When parsing expressions
	-- jstack.parsevalue and jstack.parse are recursively interlinked.
	-- This test can't be considered accurate, unless `jstack.parse` tests also pass.

	local v = jstack.parsevalue('{expression}')
	assert(v)
	assert(type(v) == "table")
	
	assert(v.type)
	assert(v.type == "expression")

	assert(v.value)
	assert(type(v.value) == "table")

	assert(type(v.value[1]) == "table")
	assert(v.value[1].chunk == '{expression}')
	assert(v.value[1].line == -1)
	assert(v.value[1].char == 9)

	assert(v.value[1].content)
	assert(v.value[1].content.type == "symbol")
	assert(v.value[1].content.value == "expression")
	assert(v.value[1].content.raw == "expression")
	
	assert(v.raw)
	assert(v.raw == '{expression}')
end
