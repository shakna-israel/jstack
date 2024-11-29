local jstack = require "./jstack"
assert(jstack)

assert(jstack.to_lua)

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

do
	for i=-1000, 1000 do
		local s = jstack.make_integer(nil, i)
		assert(s)
		assert(jstack.to_lua(s) == i)
	end
end

do
	for x=-1000, 1000 do
		for y=0, 1000 do
			local s = jstack.make_float(nil, string.format("%d.%d", x, y))
			assert(s)
			assert(jstack.to_lua(s) == tonumber(string.format("%d.%d", x, y)))
		end
	end
end

do
	-- Build an interrupt:
	local s = jstack.parsevalue("!", 1, 1)
	assert(s)
	local w = jstack.make_nil()
	w.content = s

	-- Test the conversion:
	local r = jstack.to_lua(w)
	assert(r)
	assert(r[1] == "interrupt")
	assert(r[2] == "!")
end

do
	local s = jstack.make_error(nil, "Custom", "EXTRA")
	assert(s)

	local r = jstack.to_lua(s)
	assert(r)
	assert(r[1] == "error")
	assert(r[2] == "Custom")
	assert(r[3] == "EXTRA")
end

do
	local target = jstack.make_symbol(nil, "yolo")
	local s = jstack.make_error(nil, "Custom", target)
	assert(s)

	local r = jstack.to_lua(s)
	assert(r)
	assert(r[1] == "error")
	assert(r[2] == "Custom")
	assert(r[3] == "yolo")
end

-- userdata test can only run under Luajit.
if type(jit) == 'table' then
	local ffi = require "ffi"
	ffi.cdef[[
	void *malloc(size_t size);
	void free(void *ptr);
	]]

	do
		local p = ffi.C.malloc(10)
		assert(p)
		local s = jstack.make_foreign(nil, p)

		assert(jstack.to_lua(s) == p)

		ffi.C.free(p)
	end

	do
		assert(type(ffi.C) == "userdata")
		local s = jstack.make_foreign(nil, ffi.C)

		assert(jstack.to_lua(s) == ffi.C)
	end
end

-- TODO: expression
