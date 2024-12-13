local jstack = require "./jstack"
assert(jstack)

assert(jstack.stdlib)

assert(type(jstack.stdlib()) == "table")

do
	local f = jstack.stdlib()['describe']
	assert(f)
	assert(f.chunk == "stdlib")
	assert(f.content.type == "builtin")
	assert(f.help)
	assert(f.content.value)
end

do
	-- Leaves the expression on the stack:
	local stack = {}
	local prog = [==[
	let: thing {
		add: add:
	}
	describe: "Calls add twice." thing$
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "expression")
end

do
	-- Actually installs help info:
	local stack = {}
	local prog = [==[
	let: thing {
		add: add:
	}
	describe: "Calls add twice." thing$
	help!
	]==]
	assert(jstack.eval(jstack.parse(prog), {jstack.stdlib()}, stack))
	assert(#stack == 1)
	assert(stack[1].content.type == "string")
	-- Further info is added, so we just check the start is correct:
	assert(stack[1].content.value:sub(1, #"Calls add twice.") == "Calls add twice.")
end
