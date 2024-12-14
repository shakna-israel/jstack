local jstack = require "./jstack"
assert(jstack)

assert(jstack.from_lua)

-- jstack.from_lua(caller, v, k, name)

do
	local s = jstack.from_lua(nil, "hello", nil, nil)
	assert(s)
	assert(s.content.type == "string")
	assert(s.content.value == "hello")
end

do
	local s = jstack.from_lua(nil, 10, nil, nil)
	assert(s)
	assert(s.content.type == "integer")
	assert(s.content.value == 10)
end

do
	local s = jstack.from_lua(nil, 10.1, nil, nil)
	assert(s)
	assert(s.content.type == "float")
	assert(s.content.value == 10.1)
end

do
	local s = jstack.from_lua(nil, true, nil, nil)
	assert(s)
	assert(s.content.type == "symbol")
	assert(s.content.value == "true")
end

do
	local s = jstack.from_lua(nil, false, nil, nil)
	assert(s)
	assert(s.content.type == "symbol")
	assert(s.content.value == "false")
end

do
	local s = jstack.from_lua(nil, nil, nil, nil)
	assert(s)
	assert(s.content.type == "symbol")
	assert(s.content.value == "nil")
end

do
	local functor = function()
		return true
	end

	local f = jstack.from_lua(nil, functor, nil, nil)
	assert(f)
	assert(f.content.type == "builtin")
	assert(f.content.value)
	assert(f.content.value ~= functor)

	assert(f.line == -1)
	assert(f.char == -1)
	assert(f.chunk == "<unknown>")
	assert(f.content.raw == "<<unknown>.?>")
	assert(f.help == "See <unknown> for ?.\nWarning: This function consumes the *entire* stack.")

	local stack = {}
	assert(f.content.value(nil, {}, stack))
	assert(stack[1])
	assert(stack[1].content)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")
end

do
	local functor = function()
		return true, false
	end

	local f = jstack.from_lua(nil, functor, nil, nil)
	assert(f)
	assert(f.content.type == "builtin")
	assert(f.content.value)
	assert(f.content.value ~= functor)

	assert(f.line == -1)
	assert(f.char == -1)
	assert(f.chunk == "<unknown>")
	assert(f.content.raw == "<<unknown>.?>")
	assert(f.help == "See <unknown> for ?.\nWarning: This function consumes the *entire* stack.")

	local stack = {}
	assert(f.content.value(nil, {}, stack))
	assert(stack[1])
	assert(stack[1].content)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "true")

	assert(stack[2])
	assert(stack[2].content)
	assert(stack[2].content.type == "symbol")
	assert(stack[2].content.value == "false")
end

do
	local t = {1, 2, 3}
	local s = jstack.from_lua(nil, t, nil, nil)
	assert(s)
	assert(s.chunk == "<unknown>")
	assert(s.content)
	assert(s.content.type == "expression")
	assert(type(s.content.value) == "table")
	for i=1, #s.content.value do
		assert(s.content.value[i].content.type == "integer")
		assert(s.content.value[i].content.value == i)
	end
end

do
	local t = {a=21, b=23}
	local s = jstack.from_lua(nil, t, nil, nil)
	assert(s)
	assert(s.chunk == "<unknown>")
	assert(s.content)
	assert(s.content.type == "expression")
	assert(type(s.content.value) == "table")
	for i=1, #s.content.value do
		assert(s.content.value[i].content.type == "expression")
		assert(type(s.content.value[i].content.value) == "table")

		assert(s.content.value[i].content.value[1].content.type == "string")

		assert(s.content.value[i].content.value[1].content.value == "a" or s.content.value[i].content.value[1].content.value == "b")

		assert(s.content.value[i].content.value[2].content.type == "integer")

		assert(s.content.value[i].content.value[2].content.value == 21 or s.content.value[i].content.value[2].content.value == 23)
	end
end

-- userdata test can only run under Luajit.
if type(jit) == 'table' then
	local ffi = require "ffi"
	ffi.cdef[[
	void *malloc(size_t size);
	void free(void *ptr);
	]]

	-- cdata
	do
		local p = ffi.C.malloc(10)
		assert(p)
		assert(type(p) == "cdata")


		local s = jstack.from_lua(nil, p, nil, nil)
		assert(s)
		assert(s.content)
		assert(s.content.type == "foreign")
		assert(s.content.value == p)

		ffi.C.free(p)
	end

	-- userdata
	do
		assert(type(ffi.C) == "userdata")
		local s = jstack.from_lua(nil, ffi.C, nil, nil)
		assert(s)
		assert(s.content)
		assert(s.content.type == "foreign")
		assert(s.content.value == ffi.C)
	end

end
