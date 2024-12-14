local jstack = require "./jstack"
assert(jstack)

assert(jstack.guess_filepath)
assert(type(jstack.guess_filepath) == "function")

if io and io.open then
	assert(jstack.guess_filepath("./examples/hello1") == "./examples/hello1.stk")
	assert(jstack.guess_filepath("./examples/scope") == "./examples/scope.stk")

	assert(jstack.guess_filepath("string") == "string")
	assert(jstack.guess_filepath("ffi") == "ffi")
else
	-- Luau has no file system access.

	-- So normal modules are fine:
	assert(jstack.guess_filepath("ffi") == "ffi")
	assert(jstack.guess_filepath("string") == "string")

	-- But it won't find the file matching these:
	assert(jstack.guess_filepath("./examples/scope") == "./examples/scope")
	assert(jstack.guess_filepath("./examples/hello1") == "./examples/hello1")
end
