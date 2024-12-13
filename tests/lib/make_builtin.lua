local jstack = require "./jstack"
assert(jstack)

assert(jstack.make_builtin)

do
	local functor = function(caller, env, stack)
		return true
	end

	local s = jstack.make_builtin(nil, nil, functor, nil)
	assert(s.chunk == "<unknown>")
	assert(s.line == -1)
	assert(s.char == -1)
	assert(s.content)
	assert(s.content.type == "builtin")
	assert(s.content.raw == "<<unknown>.unknown>")
	assert(s.content.value == functor)
	assert(s.help == "See <unknown> for unknown.")
end

do
	local functor = function(caller, env, stack)
		return true
	end

	local s = jstack.make_builtin(nil, nil, functor, "lol")
	assert(s.chunk == "<unknown>")
	assert(s.line == -1)
	assert(s.char == -1)
	assert(s.content)
	assert(s.content.type == "builtin")
	assert(s.content.raw == "<<unknown>.unknown>")
	assert(s.content.value == functor)
	assert(s.help == "lol")
end

do
	local functor = function(caller, env, stack)
		return true
	end

	local s = jstack.make_builtin("foo", nil, functor, "lol")
	assert(s.chunk == "<unknown>")
	assert(s.line == -1)
	assert(s.char == -1)
	assert(s.content)
	assert(s.content.type == "builtin")
	assert(s.content.raw == "<<unknown>.foo>")
	assert(s.content.value == functor)
	assert(s.help == "lol")
end

do
	local functor = function(caller, env, stack)
		return true
	end

	local s = jstack.make_builtin("foo", "bar", functor, "lol")
	assert(s.chunk == "bar")
	assert(s.line == -1)
	assert(s.char == -1)
	assert(s.content)
	assert(s.content.type == "builtin")
	assert(s.content.raw == "<bar.foo>")
	assert(s.content.value == functor)
	assert(s.help == "lol")
end
