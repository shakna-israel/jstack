local jstack = require "./jstack"
assert(jstack)

assert(jstack.tostring)

-- jstack.tostring(item)

-- TODO

do
	assert(jstack.tostring(
		jstack.make_nil(nil)
	) == '`nil`')
end

do
	assert(jstack.tostring(
		jstack.make_symbol(nil, "nil")
	) == '`nil`')
end

do
	assert(jstack.tostring(
		jstack.make_symbol(nil, "true")
	) == '`true`')
end

do
	assert(jstack.tostring(
		jstack.make_symbol(nil, "false")
	) == '`false`')
end

do
	assert(jstack.tostring(
		jstack.make_symbol(nil, "hello world")
	) == '`hello world`')
end

do
	assert(jstack.tostring(
		jstack.make_symbol(nil, "with\nnewline")
	) == '`with\nnewline`')
end

do
	assert(jstack.tostring(
		jstack.make_string(nil, "with\nnewline")
	) == "with\nnewline")
end

do
	assert(jstack.tostring(
		jstack.make_string(nil, "with")
	) == "with")
end

-- integer
do
	assert(jstack.tostring(
		jstack.make_integer(nil, "10")
	) == "10")
end

-- float
do
	assert(jstack.tostring(
		jstack.make_float(nil, "10")
	) == "10.000000")
end

-- error
do
	assert(
		jstack.tostring(
			jstack.make_error(
				{chunk="chunker", line=200, char=407, content={raw="???"}},
				"Type",
				jstack.make_symbol(nil, "target")
			)
		) == [[error<Type>(chunker 200:407)
???
`target`]]
	)
end

-- interrupt
do
	-- Build an interrupt:
	local s = jstack.parsevalue("!", 1, 1)
	assert(s)
	local w = jstack.make_nil()
	w.content = s
	assert(jstack.tostring(w) == "interrupt<!>")
end

-- expression
do
	-- Build an interrupt:
	local s = jstack.parse("{1 2 3}")
	assert(s)
	assert(s[1])
	assert(jstack.tostring(s[1]) == "{ `3` `2` `1` }")
end

-- builtin
do
	local s = jstack.make_builtin("foo", "bar", function() end, "A help.")
	assert(jstack.tostring(s) == "builtin<bar.foo>")
end

-- foreign
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

		assert(jstack.tostring(s):sub(1, 21) == "foreign<nil:nil:nil>(")
		assert(jstack.tostring(s):sub(-1) == ")")

		ffi.C.free(p)
	end

	do
		assert(type(ffi.C) == "userdata")
		local s = jstack.make_foreign(nil, ffi.C)

		assert(jstack.tostring(s):sub(1, 21) == "foreign<nil:nil:nil>(")
		assert(jstack.tostring(s):sub(-1) == ")")

		assert(jstack.to_lua(s) == ffi.C)
	end
end
