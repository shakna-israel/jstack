local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_foreign)

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

		local s = jstack.make_foreign(nil, p)
		assert(s)
		assert(s.content)
		assert(s.content.type == "foreign")
		assert(s.content.value == p)

		ffi.C.free(p)
	end

	-- userdata
	do
		assert(type(ffi.C) == "userdata")
		local s = jstack.make_foreign(nil, ffi.C)

		assert(s)
		assert(s.content)
		assert(s.content.type == "foreign")
		assert(s.content.value == ffi.C)
	end

end
