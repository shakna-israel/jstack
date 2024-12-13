local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['assert']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {jstack.make_error(nil, "Type", nil)}
	assert(jstack.eval(jstack.parse("assert!"), {jstack.stdlib()}, stack) == false)
	assert(#stack == 0)	
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("assert!"), {jstack.stdlib()}, stack) == false)
	assert(#stack == 0)	
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("assert: nil"), {jstack.stdlib()}, stack) == false)
	assert(#stack == 0)	
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("assert: false"), {jstack.stdlib()}, stack) == false)
	assert(#stack == 0)	
end

do
	local stack = {}
	assert(jstack.eval(jstack.parse("assert: hello"), {jstack.stdlib()}, stack))
	assert(#stack == 0)	
end
