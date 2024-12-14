local jstack = require "./jstack"
assert(jstack)

assert(jstack.import_lua)

-- jstack.import_lua(caller, name)

do
	local s = jstack.import_lua(nil, "bbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaadddddddddddd")
	assert(s == nil)
end

if io and io.open then
	do
		local s = jstack.import_lua(nil, "string")
		assert(s)
		for k, v in pairs(s) do
			assert(k)
			assert(v)
		end

		assert(s['string.lower'])
		assert(s['string.lower'].content)
		assert(s['string.lower'].content.type == "builtin")

		local stack = {jstack.make_string(nil, "HELLO, WORLD")}
		assert(s['string.lower'].content.value(nil, {jstack.stdlib()}, stack))
		assert(stack[#stack])
		assert(stack[#stack].content)
		assert(stack[#stack].content.type == "string")
		assert(stack[#stack].content.value == "hello, world")
	end

	do
		if utf8 then
			local s = jstack.import_lua(nil, "utf8")
			assert(s)
			for k, v in pairs(s) do
				assert(k)
				assert(v)
			end

			assert(s['utf8.charpattern'])
			assert(s['utf8.charpattern'].content)
			assert(s['utf8.charpattern'].content.type == "string")
			assert(s['utf8.charpattern'].content.value == utf8.charpattern)
		end
	end
else
	-- TODO: Luau specific tests. (Modules and filesystem are off-limits...)
end
