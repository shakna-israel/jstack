local jstack = require "./jstack"
assert(jstack)

assert(jstack.version)
assert(type(jstack.version) == "table")
assert(#jstack.version == 3)

assert(type(jstack.version[1]) == "number")
assert(type(jstack.version[2]) == "number")
assert(type(jstack.version[3]) == "number")

if math.type then
	assert(math.type(jstack.version[1]) == "integer")
	assert(math.type(jstack.version[2]) == "integer")
	assert(math.type(jstack.version[3]) == "integer")
end
