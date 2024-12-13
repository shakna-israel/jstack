local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['foreach']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	local prog = [==[
	foreach!
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	local prog = [==[
	foreach: {}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	local prog = [==[
	foreach: {} a
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	local prog = [==[
	foreach: b a
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	local prog = [==[
	foreach: {} {}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "error")
	assert(stack[1].content.value == "Type")
end

do
	local stack = {}
	local prog = [==[
	foreach: item {} {}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 0)
end

do
	-- Foreach changes object reference each time, so no need for that copying from for!
	local stack = {}
	local prog = [==[
	{
		item$
	}
	foreach: item {i3 i2 i1}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 3)
	for i=1, 3 do
		assert(stack[i].content.type)
		assert(stack[i].content.value == i)
	end
end
