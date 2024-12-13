local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['cond']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	local stack = {}
	local prog = [==[
	cond: {
		{false} {"Nope."}
		{true} {Here}
	}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "Here")
end

do
	local stack = {}
	local prog = [==[
	cond: {
		{true} {"Nope."}
		{false} {Here}
	}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "string")
	assert(stack[1].content.value == "Nope.")
end

do
	local stack = {}
	local prog = [==[
	cond: {
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{false} {"Nope."}
		{true} {Here}
	}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "Here")
end

do
	local stack = {}
	local prog = [==[
	let: a i21
	cond: {
		{equal? a$ i22} {"Nope."}
		{equal? a$ i21} {Here}
		{equal? a$ i23} {"Nope."}
	}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "Here")
end

do
	local stack = {}
	local prog = [==[
	let: a i21
	cond: {
		{
			"Nope."
		}
		{equal? a$ i22}
		
		{
			Here
		}
		{equal? a$ i21}

		{equal? a$ i23} {"Nope."}
	}
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "symbol")
	assert(stack[1].content.value == "Here")
end
