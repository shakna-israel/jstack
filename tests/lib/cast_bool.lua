local jstack = require "./jstack"
assert(jstack)

assert(jstack.cast_bool)

--jstack.cast_bool(caller, env, stack)

-- TODO
do
	local o = jstack.make_nil()
	local stack = {}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "false")
end

do
	local o = jstack.make_integer(nil, 10)
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_integer(nil, 0)
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_float(nil, 0.0)
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_float(nil, 10.0)
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_symbol(nil, "hello")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_symbol(nil, "nil")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "false")
end

do
	local o = jstack.make_symbol(nil, "false")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "false")
end

do
	local o = jstack.make_symbol(nil, "true")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_error(nil, "Type")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "false")
end

do
	local o = jstack.make_string(nil, "")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_string(nil, "hello")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_foreign(nil, "userdata")
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end

do
	local o = jstack.make_foreign(nil, nil)
	local stack = {o}
	jstack.cast_bool(o, {}, stack)
	local result = stack[#stack]
	assert(result)
	assert(result.content)
	assert(result.content.type == "symbol")
	assert(result.content.value == "true")
end
