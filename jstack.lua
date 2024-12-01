--[==[
jstack (c) 2024, James Milne

Redistribution and use in source and binary forms,
with or without modification, are permitted provided
that the following conditions are met:

1. Redistributions of source code must retain the above
copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the
above copyright notice, this list of conditions and
the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the
names of its contributors may be used to endorse or
promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS
AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

]==]

do
	local lib = {}

	lib.version = {0,0,0}

	-- Marked symbols, that begin and end with something.
	local marker = {
		['{'] = {'}', 'e'},
		['('] = {')', 'e'},

		['"'] = {'"', 's'},
		["'"] = {"'", 's'},
		['['] = {']', 's'},

		['`'] = {'`', 'y'},
		['%'] = {'%', 'y'},
	}

	-- Single-character interrupts:
	local special = {
		["!"] = true,
		["?"] = true,
		[":"] = true,
		["$"] = true,
	}

	local table_copy
	table_copy = function(item)
		if type(item) == "table" then
			local r = {}
			for k, v in pairs(item) do
				r[table_copy(k)] = table_copy(v)
			end
			return r
		else
			return item
		end
	end

	local isarray = function(value)
		if type(value) ~= "table" then
			return false
		end

		local ikeys = {}
		local keys = {}
		for idx, _ in ipairs(value) do
			ikeys[#ikeys + 1] = idx
		end
		for k, _ in pairs(value) do
			keys[#keys + 1] = k
		end

		if #ikeys ~= #keys then
			return false
		end

		for i = 1, #keys do
			if keys[i] ~= ikeys[i] then
				return false
			end
		end

		return true
	end

	lib.parsevalue = function(token, line, char)
		-- Create objects from literals

		local token = token or ""
		local line = (line ~= nil and line) or -1
		local char = (char ~= nil and char) or -1

		-- Instruction handling:
		for k, v in pairs(special) do
			if k == token then
				local datum = {}
				datum['type'] = 'interrupt'
				datum['value'] = token
				datum['raw'] = token
				return datum
			end
		end

		-- Marked tokens::
		if #token > 1 then
			for begin, cell in pairs(marker) do
				if token:sub(1, 1) == begin and token:sub(#token) == cell[1] then
					-- Strings
					if cell[2] == 's' then
						local datum = {}
						datum['type'] = 'string'
						datum['value'] = token:sub(2, #token - 1)
						datum['raw'] = token
						return datum
					-- Expressions
					elseif cell[2] == 'e' then
						local datum = {}
						datum['type'] = 'expression'
						datum['value'] = lib.parse(token:sub(2, #token - 1), token, line, char)
						datum['raw'] = token
						return datum
					-- Symbols
					elseif cell[2] == 'y' then
						local datum = {}
						datum['type'] = 'symbol'
						datum['value'] = token:sub(2, #token - 1)
						datum['raw'] = token
						return datum
					else
						-- Error:
						error(string.format("Unknown Marked Token: %q for %s", cell[2], cell[1]))
					end
				end
			end
		end

		-- Number types
		if token:sub(1, 1) == 'i' and tonumber(token:sub(2)) ~= nil then
			-- Integer
			local datum = {}
			datum['type'] = 'integer'
			datum['value'] = math.floor(tonumber(token:sub(2)))
			datum['raw'] = token
			return datum
		elseif token:sub(1, 1) == 'f' and tonumber(token:sub(2)) ~= nil then
			-- Float
			local datum = {}
			datum['type'] = 'float'
			datum['value'] = tonumber(token:sub(2))
			datum['raw'] = token
			return datum
		end

		-- Symbols:
		local datum = {}
		datum['type'] = 'symbol'
		datum['value'] = token
		datum['raw'] = token
		return datum
	end

	lib.parse = function(content, chunkname, line, char)
		local chunkname = chunkname or "<unknown>"
		local line = line or 1
		local char = char or 0
		local content = content or ""
		local in_expression = 0
		local check_expression = {}
		local in_string = false
		local token = {}
		local expression = {}
		local tree = {}
		local in_comment = false
		local meta = {}

		local whitespace = {
			[' '] = true,
			['\t'] = true,
			['\n'] = true,
			['\r'] = true,
		}

		local comment = {
			[';'] = '\n',
			['~'] = '~',
		}

		local hex_escape = {}
		local int_escape = {}

		for i=1, #content do
			local c = content:sub(i, i)

			if c == "\n" then
				line = line + 1
				char = 0
			else
				char = char + 1
			end
			if not meta['line'] then
				meta['line'] = line
			end
			if not meta['char'] then
				meta['char'] = char
			end

			if in_comment then
				if c == in_comment then
					in_comment = false
				end
			elseif in_string then
				-- Process a hex escape: \xDD
				if #hex_escape > 0 then
					if #hex_escape > 2 then
						table.remove(token, #token)
						local v = (concat or table.concat)(hex_escape)
						while #hex_escape > 0 do
							table.remove(hex_escape, #hex_escape)
						end
						token[#token] = string.char(tonumber(v, 16) or 0)
						token[#token + 1] = c
					else
						hex_escape[#hex_escape + 1] = c
					end
				-- Process a decimal escape: \DDD
				elseif #int_escape > 0 then
					if #int_escape > 2 then
						table.remove(token, #token)
						local v = (concat or table.concat)(int_escape)
						while #int_escape > 0 do
							table.remove(int_escape, #int_escape)
						end
						token[#token] = string.char(tonumber(v, 10) or 0)
						token[#token + 1] = c
					else
						int_escape[#int_escape + 1] = c
					end
				elseif token[#token] == '\\' then
					-- Escaping:
					if c == 'a' then
						token[#token] = '\a'
					elseif c == 'b' then
						token[#token] = '\b'
					elseif c == 'f' then
						token[#token] = '\f'
					elseif c == 'n' then
						token[#token] = '\n'
					elseif c == 'r' then
						token[#token] = '\r'
					elseif c == 't' then
						token[#token] = '\t'
					elseif c == 'v' then
						token[#token] = '\v'
					elseif c == 'x' then
						-- \xAA for hex:
						hex_escape[#hex_escape + 1] = "0"
					elseif tonumber(c) ~= nil and tonumber(c) > -1 and tonumber(c) < 10 then
						-- \ddd for decimal.
						int_escape[#int_escape + 1] = "0"
					else
						token[#token] = c
					end
					token[#token + 1] = ''
				elseif c == in_string then
					token[#token+1] = c
					in_string = false
				else
					token[#token+1] = c
				end
			elseif in_expression > 0 then
				if c == check_expression[1] then
					in_expression = in_expression + 1
				elseif c == check_expression[2] then
					in_expression = in_expression - 1
				end
				token[#token + 1] = c
			elseif marker[c] then
				token[#token + 1] = c
				if marker[c][2] == 'e' then
					in_expression = in_expression + 1
					check_expression = {c, marker[c][1]}
				elseif marker[c][2] == 's' then
					in_string = marker[c][1]
				elseif marker[c][2] == 'y' then
					in_string = marker[c][1]
				else
					-- Error
					error(string.format("Critical Parser Bug: %s for %q", c, (concat or table.concat)(token)))
				end
			elseif comment[c] then
				in_comment = comment[c]
			elseif whitespace[c] or special[c] then
				if special[c] then
					local datum = {}
					datum.content = lib.parsevalue(c, meta['line'] or line, meta['char'] or char)
					datum.line = line
					datum.char = char
					datum.chunk = chunkname
					expression[#expression + 1] = datum
				end

				if #token > 0 then
					local datum = {}
					datum.content = lib.parsevalue(table.concat(token), meta['line'] or line, meta['char'] or char)
					token = {}
					datum.line = line
					datum.char = char
					datum.chunk = chunkname
					expression[#expression + 1] = datum
				end

				if c == '\n' then
					while #expression > 0 do
						tree[#tree + 1] = table.remove(expression, #expression)
					end
				end
				meta = {}
			else
				token[#token + 1] = c
			end
		end

		if #token > 0 then
			local datum = {}
			datum.content = lib.parsevalue(table.concat(token), meta['line'] or line, meta['char'] or char)
			token = {}
			datum.line = line
			datum.char = char
			datum.chunk = chunkname
			expression[#expression + 1] = datum
			meta = {}
		end
		while #expression > 0 do
			tree[#tree + 1] = table.remove(expression, #expression)
		end
		
		return tree
	end

	lib.tostring = function(item)
		if not item then return "" end

		if type(item) ~= "table" then
			return tostring(item)
		end

		if item.content.type == "builtin" then
			return string.format("%s%s",
				item.content.type,
				item.content.raw)
		elseif item.content.type == "expression" then
			local tmp_t = {}
			for idx, cell in ipairs(item.content.value) do
				tmp_t[#tmp_t + 1] = lib.tostring(cell)
			end
			local tmp_s = (concat or table.concat)(tmp_t, " ")
			return string.format("{ %s }", tmp_s)
		elseif item.content.type == "string" then
			return item.content.value
		elseif item.content.type == "integer" then
			return string.format("%d", item.content.value)
		elseif item.content.type == "float" then
			return string.format("%f", item.content.value)
		elseif item.content.type == "symbol" then
			return string.format("`%s`", item.content.value)
		elseif item.content.type == "error" then
			return string.format("error<%s>(%s %s:%s)\n%s\n%s",
				lib.tostring(item.content.value),
				item.chunk,
				item.line,
				item.char,
				item.content.raw,
				lib.tostring(item.content.extra or nil)
			)
		elseif item.content.type == "foreign" then
			return string.format("foreign<%s:%s:%s>", item.chunk, item.line, item.char)
		elseif item.content.type == "interrupt" then
			return string.format("interrupt<%s>", item.content.value)
		else
			-- Error. Unreachable.
			error(string.format("Critical Bug. Should be unreachable for %q", item.content.type))
		end
	end

	lib.make_builtin = function(funcname, chunkname, functor, helpdoc)
		local funcname = funcname or "unknown"
		local chunkname = chunkname or "<unknown>"
		local helpdoc = helpdoc or string.format("See %s for %s.", chunkname, funcname)
		return {
			line = -1,
			char = -1,
			chunk = chunkname or "<unknown>",
			content = {
				raw = string.format("<%s.%s>", chunkname, funcname),
				type = "builtin",
				value = functor,
			},
			help = helpdoc
		}
	end

	lib.from_lua = function(caller, v, k, name)
		-- TODO: Convert a Lua primitive to a jstack value.
		local k = k or "?"
		local name = name or "<unknown>"

		local caller = caller or {}
		caller.content = caller.content or {}

		if v == nil then
			return lib.make_nil(caller)
		elseif type(v) == "table" then
			-- TODO: Convert interrupt representation
			-- TODO: Convert error representation

			-- Convert to expression
			local tree = lib.parse("{}", caller.chunk, caller.line, caller.char)
			tree.chunk = caller.chunk
			tree.line = caller.line
			tree.char = caller.char
			if isarray(v) then
				-- Expression as list:
				local t = {}
				for i=1, #v do
					t[#t + 1] = lib.from_lua(caller, v[i], k, name)
				end

				tree[1].content.value = t
				return tree[1]
			else
				-- Expression as list of pairs:
				local t = {}
				for kname, cellv in pairs(v) do
					t[#t + 1] = lib.from_lua(caller, {kname, cellv}, k, name)
				end
				tree[1].content.value = t
				return tree[1]
			end

		elseif type(v) == "function" then
			return lib.make_builtin(k, name, (function(lua_func)
				return function(caller, env, stack)
					-- Lua functions consume the *entire* stack.

					-- Convert stack args to Lua primitives.
					local nstack = {}
					while #stack > 0 do
						local v = table.remove(stack, #stack)
						nstack[#nstack + 1] = lib.to_lua(v)
					end

					local r = {pcall(lua_func, (unpack or table.unpack)(nstack))}

					if r[1] then
						table.remove(r, 1)
						while true do
							if #r == 0 then
								break
							end
							stack[#stack + 1] = lib.from_lua(caller, r[1])
							table.remove(r, 1)
						end
						return true
					else
						-- Lua functions throw a Critical:
						return false
					end
				end
			end)(v),
			string.format("See %s for %s.\nWarning: This function consumes the *entire* stack.", name, k))
		elseif type(v) == "string" then
			return lib.make_string(caller, v)
		elseif type(v) == "number" then
			if (math.type and math.type(v) == "integer") or (math.floor(v) == v) then
				-- Integer
				return lib.make_integer(caller, v)
			else
				-- Float
				return lib.make_float(caller, v)
			end
		elseif type(v) == "boolean" then
			return lib.make_symbol(caller, tostring(v))
		elseif type(v) == "userdata" or type(v) == "cdata" then
			return lib.make_foreign(caller, v)
		end
	end

	lib.to_lua = function(value)
		if type(value) ~= "table" then
			return value
		end

		-- Convert a jstack value into a Lua primitive
		if value.content.type == "string" then
			return value.content.value
		elseif value.content.type == "symbol" then
			if value.content.value == "nil" then
				return nil
			elseif value.content.value == "true" then
				return true
			elseif value.content.value == "false" then
				return false
			else
				return value.content.value
			end
		elseif value.content.type == "expression" then
			local r = {}
			for idx, child in ipairs(value.content.value) do
				r[#r + 1] = lib.to_lua(child)
			end
			return r
		elseif value.content.type == "error" then
			return {"error", value.content.value, lib.to_lua(value.content.extra)}
		elseif value.content.type == "integer" then
			return value.content.value
		elseif value.content.type == "float" then
			return value.content.value
		elseif value.content.type == "foreign" then
			return value.content.value
		elseif value.content.type == "interrupt" then
			return {"interrupt", value.content.value}
		else
			error(string.format("Unknown Type: %q for %s", value.content.type, value))
		end
	end

	lib.import_lua = function(caller, name)
		local check = {pcall(require, name)}
		if check[1] then
			local x = check[2]
			if not x then
				return nil
			end
			local env = {}

			for k, v in pairs(x) do
				env[string.format("%s.%s", name, k)] = lib.from_lua(caller, v, k, string.format("lua:%s", name))
			end

			return env
		else
			return nil
		end
	end

	lib.guess_filepath = function(name, source)
		-- Guess the path for importing...

		-- TODO: Allow modifying at runtime...

		-- Get relative to host file location:
		if source then
			for i=#source, 1, -1 do
				local c = source:sub(i, i)
				if c == "/" or c == "\\" then
					local v = lib.guess_filepath(source:sub(1, i) .. name)
					if v then
						return v
					end
				end
			end
		end

		local try = name
		local f = io.open(try)
		if f then
			f:close()
			return try
		end

		try = string.format("%s.stk", name)
		f = io.open(try)
		if f then
			f:close()
			return try
		end
		try = string.format("%s", name)
		local check = {pcall(require, try)}
		if check[1] and check[2] then
			return try
		end

		local dir = os.getenv("APPDATA")
		if dir then
			try = string.format("%s/%s.stk", dir, name)
			f = io.open(try)
			if f then
				f:close()
				return try
			end

			try = string.format("%s/%s", dir, name)
			local check = {pcall(require, try)}
			if check[1] and check[2] then
				return try
			end
		end

		local dir = os.getenv("XDG_DATA_HOME")
		if dir then
			try = string.format("%s/jstack/%s.stk", dir, name)
			f = io.open(try)
			if f then
				f:close()
				return try
			end

			try = string.format("%s/jstack/%s", dir, name)
			local check = {pcall(require, try)}
			if check[1] and check[2] then
				return try
			end
		end

		local dir = os.getenv("HOME")
		if dir then
			try = string.format("%s/.share/local/jstack/%s.stk", dir, name)
			f = io.open(try)
			if f then
				f:close()
				return try
			end

			try = string.format("%s/.share/local/jstack/%s", dir, name)
			local check = {pcall(require, try)}
			if check[1] and check[2] then
				return try
			end
		end

		local dir = os.getenv("HOME")
		if dir then
			try = string.format("%s/.jstack/%s.stk", dir, name)
			f = io.open(try)
			if f then
				f:close()
				return try
			end

			try = string.format("%s/.jstack/%s", dir, name)
			local check = {pcall(require, try)}
			if check[1] and check[2] then
				return try
			end
		end

		return name
	end

	lib.stdenv = function()
		-- TODO: Environment modifying operations
		local r = {}

		return r
	end

	lib.stdio = function()
		-- TODO: File operations
		local r = {}

		return r
	end

	lib.stdexpression = function()
		-- TODO: List stuff for expressions (append, etc)
		local r = {}

		-- TODO: Also add eval stuff here.

		return r
	end

	lib.stdpattern = function()
		-- TODO: List stuff for Lua patterns
		local r = {}

		return r
	end

	lib.stdcoroutine = function()
		-- TODO: List stuff for Lua coroutines
		local r = {}

		return r
	end

	lib.stdconfig = function()
		-- Limited eval of jstack to use as config files.
		-- Probably only allow if, cond and let.
		local r = {}

		r['loadstring'] = lib.make_builtin('loadstring', 'stdconfig',
			function(caller, env, stack)
				local source = table.remove(stack, #stack) or lib.make_string(caller, "")
				local tree = lib.parse(lib.tostring(source))

				local stdlib = lib.stdlib()
				local new_env = {}
				new_env['if'] = stdlib['if']
				new_env['let'] = stdlib['let']
				new_env['cond'] = stdlib['cond']
				new_env['clear'] = stdlib['clear']
				new_env[#new_env + 1] = {}

				local new_stack = {}

				local catch = {lib.eval(tree, {new_env}, new_stack)}
				if not catch[1] then
					return false, catch[2]
				end

				local s = lib.parse("{}")
				if not s or not s[1] then
					return false
				end
				
				local new_wrap = s[1]
				new_wrap.chunk = caller.chunk
				new_wrap.line = caller.line
				new_wrap.char = caller.char
				new_wrap.content.raw = source
				new_wrap.content.value = new_stack

				stack[#stack + 1] = new_wrap
				return true
			end,
			[[Pops one value from the top of the stack and casts to a string.
It then parses that string, and runs it in a limited environment.
The entire stack is returned as a new expression.
Errors from parsing and evaluation are propagated.
]]
		)

		r['loadfile'] = lib.make_builtin('loadstring', 'stdconfig',
			function(caller, env, stack)
				local fname = table.remove(stack, #stack)
				local source = ""
				if fname then
					local f = io.open(tostring(fname.content.value))
					if f then
						source = f:read("*all")
					end
				end

				local tree = lib.parse(source)

				local stdlib = lib.stdlib()
				local new_env = {}
				new_env['if'] = stdlib['if']
				new_env['let'] = stdlib['let']
				new_env['cond'] = stdlib['cond']
				new_env['clear'] = stdlib['clear']
				new_env[#new_env + 1] = {}

				local new_stack = {}

				local catch = {lib.eval(tree, {new_env}, new_stack)}
				if not catch[1] then
					return false, catch[2]
				end
				
				local s = lib.parse("{}")
				if not s or not s[1] then
					return false
				end
				
				local new_wrap = s[1]
				new_wrap.chunk = caller.chunk
				new_wrap.line = caller.line
				new_wrap.char = caller.char
				new_wrap.content.raw = source
				new_wrap.content.value = new_stack

				stack[#stack + 1] = new_wrap
				return true
			end,
			[[Pops one value from the top of the stack and reads from a file with a matching name.
It then parses that string, and runs it in a limited environment.
The last value on the isolated stack is returned to the main stack.
Errors from parsing and evaluation are propagated.
]]
		)

		return r
	end

	lib.stderror = function()
		local r = {}

		r['throw'] = lib.make_builtin('throw', 'stderror',
			function(caller, env, stack)
				local target = table.remove(stack, #stack)

				if target.content.value == "Critical" then
					return false
				else
					stack[#stack + 1] = lib.make_error(caller, target.content.value, target)
					return true
				end
			end,
			[[Given a symbol from a stack, constructs that kind of error.
e.g. throw! Type]]
		)

		r['catch'] = lib.make_builtin('catch', 'stderror',
			function(caller, env, stack)
				local target = table.remove(stack, #stack)
				local catchname = table.remove(stack, #stack)
				local catchexp = table.remove(stack, #stack)

				if not target then
					stack[#stack + 1] = lib.make_error(caller, "Value", caller)
					return true
				end
				if not catchname then
					stack[#stack + 1] = lib.make_error(caller, "Value", caller)
					return true
				end
				if not catchexp then
					stack[#stack + 1] = lib.make_error(caller, "Value", caller)
					return true
				end

				if target.content.type ~= "expression" then
					stack[#stack + 1] = lib.make_error(target, "Type", caller)
					return true
				end
				if catchexp.content.type ~= "expression" then
					stack[#stack + 1] = lib.make_error(catchexp, "Type", caller)
					return true
				end

				local attempt = true
				local err = false

				local len = #env
				env[#env+1] = {}
				-- TODO: Should we bind target to env['self']...?
				local catch = {lib.eval(target.content.value, env, stack)}
				if not catch[1] then
					-- Drop the error, as we're binding to it anyway:
					table.remove(stack, #stack)
					attempt = false
					err = catch[2]
				elseif stack[#stack] and stack[#stack].content.type == "error" then
					attempt = false
					err = table.remove(stack, #stack)
				end
				while #env > len do
					table.remove(env, #env)
				end

				if attempt == false then
					local len = #env
					env[#env+1] = {
						[catchname.content.value] = err
					}
					-- TODO: Should we bind target to env['self']...?
					local catch = {lib.eval(catchexp.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end
					while #env > len do
						table.remove(env, #env)
					end
				end

				return true
			end,
			[[Pops the target expression from the stack,
then the symbol to bind for the caught value,
then the catch expression from the stack.
If target or catch are not provided, then a error<Value> is pushed and returns.
If target or catch are not expressions, then a error<Type> is pushed and returns.

The target is then evaluated.
If it exits poorly,
then the result is bound to the symbol given,
then the catch expression is evaluated.
]]
		)

		r['type'] = lib.make_builtin('type', 'stderror',
			function(caller, env, stack)
				local target = table.remove(stack, #stack) or lib.make_nil(caller)
				if target.content.type ~= "error" then
					stack[#stack + 1] = lib.make_nil(target)
					return true
				else
					stack[#stack + 1] = lib.make_symbol(target, target.content.value)
					return true
				end
			end,
			[[Given a value from the top of the stack:
If not an error, pushes the `nil` symbol.
Else, pushes a symbol equal to the type of the error.]]
		)

		return r
	end

	lib.stdlib = function()
		local r = {}

		r['clear'] = lib.make_builtin("clear", "stdlib",
			function(caller, env, stack)
				while #stack > 0 do
					table.remove(stack, #stack)
				end
				return true
			end,
			"Drop the entire stack."
		)

		r['drop'] = lib.make_builtin("drop", "stdlib",
			function(caller, env, stack)
				if #stack > 0 then
					table.remove(stack, #stack)
				end
				return true
			end,
			"Drop the top value on the stack."
		)

		r['help'] = lib.make_builtin("help", "stdlib",
			function(caller, env, stack)
					local target = table.remove(stack, #stack)
					local v = false
					if target.content.type == "symbol" then
						v = lib.lookup(caller, target, env) or lib.make_nil(caller)
					else
						v = target
					end

					local s = (v.help or "<no help>")
					s = s .. "\n" .. string.format("[%s] <%s:%s:%s>\n%s",
						v.content.type,
						v.chunk,
						(v.line > -1 and v.line) or "",
						(v.char > -1 and v.char) or "",
						v.content.raw)

					stack[#stack + 1] = lib.make_string(caller, s)
					return true
				end,
				[[Pops one from stack.
If a symbol, looks up from current environment.
Then pushes a string containing any help information for the given item to the stack.]]
		)

		r['describe'] = lib.make_builtin("describe", "stdlib",
			function(caller, env, stack)
				local help = table.remove(stack, #stack)
				local target = stack[#stack]
				if not target or not help then
					stack[#stack + 1] = lib.make_error(caller, "Type", target)
					return true
				end

				target.help = help.content.value
				return true
			end,
			[[The first item on the stack should be a string representing the help information to install.
The second item should be the value to install the help information into. (See also `dupe`).
This function pops the help information, *but leaves the second item on the stack*.
]]
		)

		r['print'] = lib.make_builtin("print", "stdlib",
			function(caller, env, stack)
				local target = table.remove(stack, #stack)
				if target then
					print(lib.tostring(target))
				else
					print()
				end
				return true
			end,
			[[Pops the top most item from the stack.
If none, treats it as an empty string.
Converts the item to a string, and prints it to stdout.
Appends a newline to the end of the output.]])

		r['assert'] = lib.make_builtin("assert", "stdlib",
			function(caller, env, stack)
				local target = table.remove(stack, #stack)
				if target == nil or target.content.type == "error" then
					return false, lib.make_error(target or caller, target or "Critical")
				end
				return true
			end,
			[[If the top value on the stack is not an error, it is popped.
If the stack is empty, or the top value was an error, then a Critical is thrown.]]
		)

		r['type'] = lib.make_builtin('type', 'stdlib',
			function(caller, env, stack)
				local target = table.remove(stack, #stack) or lib.make_nil(caller)
				stack[#stack+1] = lib.make_symbol(caller, target.content.type)
				return true
			end,
			[[Pops top of the stack, and pushes a symbol containing the type to the top of the stack.
If the stack is empty, symbol is returned, as if it were `nil`.]]
		)

		r['import'] = lib.make_builtin("import", "stdlib",
			function(caller, env, stack)
				local target = table.remove(stack, #stack)

				if target.content.value:sub(1, 3) == "std" and lib[target.content.value] then
					local environ = {}
					for k, v in pairs(lib[target.content.value]()) do
						environ[string.format("%s.%s", target.content.value, k)] = v
					end
					env[#env + 1] = environ
					stack[#stack + 1] = lib.make_symbol(caller, "true")
				else
					-- Find something to import instead of a builtin:
					local environ = {lib.stdlib()}
					local f = io.open(lib.guess_filepath(target.content.value, caller.chunk))
					if f then
						local catch = {lib.eval(lib.parse(f:read("*all")), environ)}
						if not catch[1] then
							f:close()
							return false, catch[2]
						end
						f:close()
						local new_env = {}
						for k, v in pairs(environ) do
							new_env[string.format("%s.%s", k, target.content.value)] = v
						end
						env[#env + 1] = new_env
					else
						-- Allow importing a Lua module...
						local environ = lib.import_lua(caller, target.content.value)
						if environ then
							env[#env + 1] = environ
						else
							stack[#stack + 1] = lib.make_error(caller, "Import", target)
						end
					end
				end
				return true
			end,
			"TODO"
		)

		r['swap'] = lib.make_builtin("swap", "stdlib",
			function(caller, env, stack)
				local a = table.remove(stack, #stack) or lib.make_nil(caller)
				local b = table.remove(stack, #stack) or lib.make_nil(caller)

				stack[#stack + 1] = a
				stack[#stack + 1] = b
				return true
			end,
			[[Pops top two values of the stack, swaps their order, and pushes back to the stack.
If a value doesn't exist because nothing was on the stack, a symbol with the value of nil is inserted.]])

		r['dupe'] = lib.make_builtin("dupe", "stdlib",
			function(caller, env, stack)
				local a = stack[#stack] or lib.make_nil(caller)
				stack[#stack + 1] = a

				return true
			end,
			[[Duplicates the top stack item as a reference to the original.
See also, `copy`.]])

		r['copy'] = lib.make_builtin("copy", "stdlib",
			function(caller, env, stack)
				local a = stack[#stack] or lib.make_nil(caller)

				stack[#stack + 1] = table_copy(a)
				return true
			end,
		"Copies the top stack item, making a unique object.\nSee also, `dupe`.")

		r['let'] = lib.make_builtin("let", "stdlib",
			function(caller, env, stack)
				-- Install a reference into the current scope.
				local name = table.remove(stack, #stack)
				local value = table.remove(stack, #stack)

				if not value or not name then
					return false
				end

				env[#env][name.content.value] = value
				return true
			end,
			[[Takes the name, and then value,
from the top of the stack,
and binds it into the current environment.]]
		)

		r['get'] = lib.make_builtin("get", "stdlib",
			function(caller, env, stack)
				local target = table.remove(stack, #stack)
				if not target then
					stack[#stack + 1] = lib.make_nil(caller)
					return true
				end
				local v = lib.lookup(caller, target, env) or lib.make_nil(target)
				stack[#stack + 1] = v
				return true
			end,
			[[Pops the symbol at the top of the stack,
then pushes either a symbol with the value of nil,
or the first matching item from the environment.]])

		-- TODO: Expose this so we can use it globally.
		r['equal'] = lib.make_builtin("equal", "stdlib",
			function(caller, env, stack)
				local a = table.remove(stack, #stack) or lib.make_nil(caller)
				local b = table.remove(stack, #stack) or lib.make_nil(caller)

				if a.content.type ~= b.content.type then
					stack[#stack + 1] = lib.make_symbol(caller, "false")
					return true
				end

				if a.content.type == "expression" then
					-- TODO
					stack[#stack + 1] = lib.make_symbol(caller, "false")
					return true
				end

				if a.content.type == "integer" or a.content.type == "float" then
					if a.content.value == b.content.value then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				end

				if a.content.value == b.content.value then
					stack[#stack + 1] = lib.make_symbol(caller, "true")
					return true
				end

				stack[#stack + 1] = lib.make_symbol(caller, "false")
				return true
			end,
			[[Pops two items from the stack.
Pushes a single symbol of either `true` or `false` depending on if the
two values are comparable.]]
		)

		r['is'] = lib.make_builtin('is', 'stdlib',
			function(caller, env, stack)
				-- Compare types
				local type = table.remove(stack, #stack)
				local target = table.remove(stack, #stack)

				if type.content.value == "string" then
					if target.content.type == "string" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				elseif type.content.value == "symbol" then
					if target.content.type == "symbol" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				elseif type.content.value == "integer" then
					if target.content.type == "integer" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				elseif type.content.value == "float" then
					if target.content.type == "float" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				elseif type.content.value == "error" then
					if target.content.type == "error" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				elseif type.content.value == "expression" then
					if target.content.type == "expression" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				elseif type.content.value == "interrupt" then
					if target.content.type == "interrupt" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				elseif type.content.value == "foreign" then
					if target.content.type == "foreign" then
						stack[#stack + 1] = lib.make_symbol(caller, "true")
						return true
					else
						stack[#stack + 1] = lib.make_symbol(caller, "false")
						return true
					end
				else
					stack[#stack + 1] = lib.make_error(caller, "Type", target)
					return true
				end
			end,
			[[Given a type as a symbol, and then a target,
from the top of the stack,
pushes a resulting symbol onto the stack of either `true` or `false`.
An unknown type will push a error<Type>.]]
		)

		r['not'] = lib.make_builtin('not', 'stdlib',
			function(caller, env, stack)
				local target = table.remove(stack, #stack) or lib.make_nil(caller)
				stack[#stack + 1] = target
				lib.cast_bool(caller, env, stack)
				local result = table.remove(stack, #stack)
				if result.content.value == "true" then
					stack[#stack + 1] = lib.make_symbol(caller, "false")
				else
					stack[#stack + 1] = lib.make_symbol(caller, "true")
				end
				return true
			end,
			[[Casts top of stack to bool like the `?` interrupt, and then inverts the result.]]
		)

		r['not-equal'] = lib.make_builtin('not-equal', 'stdlib',
			function(caller, env, stack)
				r['equal'].content.value(caller, env, stack)
				r['not'].content.value(caller, env, stack)
				return true
			end,
			[[Calls equal, and then not.]]
		)

		r['or'] = lib.make_builtin('or', 'stdlib',
			function(caller, env, stack)
				local a = table.remove(stack, #stack) or lib.make_nil(caller)
				local b = table.remove(stack, #stack) or lib.make_nil(caller)

				stack[#stack + 1] = a
				lib.cast_bool(caller, env, stack)
				local result = table.remove(stack, #stack)
				if result.content.value == "true" then
					stack[#stack + 1] = a
					return true
				end

				stack[#stack + 1] = b
				lib.cast_bool(caller, env, stack)
				local result = table.remove(stack, #stack)
				if result.content.value == "true" then
					stack[#stack + 1] = b
					return true
				end

				stack[#stack + 1] = lib.make_nil(caller)
				return true
			end,
		[[Pops two items from the stack.
Pushes one of the following:
* The first, if it casts to `true` with the `?` interrupt.
* The second, if it casts to `true` with the `?` interrupt.
* `nil` as a symbol.
]])

		r['nop'] = lib.make_builtin('nop', 'stdlib',
			function(caller, env, stack)
				return true
			end,
		[[A function that does exactly nothing.]])

		r['less-than'] = lib.make_builtin('less-than', 'stdlib',
			function(caller, env, stack)
				local a = table.remove(stack, #stack) or lib.make_nil(caller)
				local b = table.remove(stack, #stack) or lib.make_nil(caller)

				if a.content.type ~= 'integer' and a.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(a, "Type", caller)
					return true
				end

				if b.content.type ~= 'integer' and b.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				if a.content.type ~= b.content.type then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				stack[#stack + 1] = lib.make_symbol(caller, a.content.value < b.content.value)
				return true
			end,
		[[Given two items from the stack, where both are either integer or float,
pushes a symbol of either `true` or `false`, measuring:
	first < second
If the expected types or constraints are not met, pushes an error<Type>.]])

		r['less-than-equal'] = lib.make_builtin('less-than-equal', 'stdlib',
			function(caller, env, stack)
				local a = table.remove(stack, #stack) or lib.make_nil(caller)
				local b = table.remove(stack, #stack) or lib.make_nil(caller)

				if a.content.type ~= 'integer' and a.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(a, "Type", caller)
					return true
				end

				if b.content.type ~= 'integer' and b.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				if a.content.type ~= b.content.type then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				stack[#stack + 1] = lib.make_symbol(caller, a.content.value <= b.content.value)
				return true
			end,
		[[Given two items from the stack, where both are either integer or float,
pushes a symbol of either `true` or `false`, measuring:
	first <= second
If the expected types or constraints are not met, pushes an error<Type>.]])

		r['greater-than'] = lib.make_builtin('greater-than', 'stdlib',
			function(caller, env, stack)
				local a = table.remove(stack, #stack) or lib.make_nil(caller)
				local b = table.remove(stack, #stack) or lib.make_nil(caller)

				if a.content.type ~= 'integer' and a.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(a, "Type", caller)
					return true
				end

				if b.content.type ~= 'integer' and b.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				if a.content.type ~= b.content.type then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				stack[#stack + 1] = lib.make_symbol(caller, a.content.value > b.content.value)
				return true
			end,
		[[Given two items from the stack, where both are either integer or float,
pushes a symbol of either `true` or `false`, measuring:
	first > second
If the expected types or constraints are not met, pushes an error<Type>.]])

		r['greater-than-equal'] = lib.make_builtin('greater-than-equal', 'stdlib',
			function(caller, env, stack)
				local a = table.remove(stack, #stack) or lib.make_nil(caller)
				local b = table.remove(stack, #stack) or lib.make_nil(caller)

				if a.content.type ~= 'integer' and a.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(a, "Type", caller)
					return true
				end

				if b.content.type ~= 'integer' and b.content.type ~= 'float' then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				if a.content.type ~= b.content.type then
					stack[#stack+1] = lib.make_error(b, "Type", caller)
					return true
				end

				stack[#stack + 1] = lib.make_symbol(caller, a.content.value >= b.content.value)
				return true
			end,
		[[Given two items from the stack, where both are either integer or float,
pushes a symbol of either `true` or `false`, measuring:
	first >= second
If the expected types or constraints are not met, pushes an error<Type>.]])

		r['within'] = lib.make_builtin('within', 'stdlib',
			function(caller, env, stack)
				local target = table.remove(stack, #stack) or lib.make_nil(caller)
				local start = table.remove(stack, #stack) or lib.make_nil(caller)
				local end_pos = table.remove(stack, #stack) or lib.make_nil(caller)

				if not target or not start or not end_pos then
					stack[#stack + 1] = lib.make_error(caller, "Type", caller)
					return true
				end

				if target.content.type ~= "integer" and target.content.type ~= "float" then
					stack[#stack + 1] = lib.make_error(target, "Type", caller)
					return true
				end

				if target.content.type ~= start.content.type then
					stack[#stack + 1] = lib.make_error(start, "Type", caller)
					return true
				elseif target.content.type ~= end_pos.content.type then
					stack[#stack + 1] = lib.make_error(end_pos, "Type", caller)
					return true
				end

				if target.content.value > start.content.value and target.content.value < end_pos.content.value then
					stack[#stack + 1] = lib.make_symbol(caller, "true")
					return true
				else
					stack[#stack + 1] = lib.make_symbol(caller, "false")
					return true
				end

				return false
			end,
			[[Given a value, a start comparison, and an end comparison,
Pushes a symbol of `true` or `false` if the value is within the range given by both.
If the comparisons are of a different type to the value, or anything is not an integer or float,
pushes an error<Type>.

e.g.
	> within! 10 1 100
	`true`
]]
		)

		-- TODO: find <value> <expression> (index/`false`)
		-- TODO: contains <value> <expression> (`true`/`false`)
		-- TODO: index <expression> <value> (value/error<Value>)

		r['to'] = lib.make_builtin('to', 'stdlib',
			function(caller, env, stack)
				local cast = table.remove(stack, #stack)
				local target = table.remove(stack, #stack)
				
				if cast.content.value == "string" then
					if type(target.content.value) == "table" then
						local inner = item.content.raw
						local v = lib.make_string(caller, inner)
						stack[#stack + 1] = v
						return true
					else
						local inner = tostring(target.content.value)
						local v = lib.make_string(caller, inner)
						stack[#stack + 1] = v
						return true
					end
				elseif cast.content.value == "symbol" then
					if type(target.content.value) == "table" then
						local inner = item.content.raw
						local v = lib.make_symbol(caller, inner)
						stack[#stack + 1] = v
						return true
					else
						local inner = tostring(target.content.value)
						local v = lib.make_symbol(caller, inner)
						stack[#stack + 1] = v
						return true
					end
				elseif cast.content.value == "integer" then
					if type(target.content.value) == "table" then
						stack[#stack + 1] = lib.make_error(caller, "Type", target)
						return true
					else
						local inner = tonumber(target.content.value)
						if inner == nil then
							stack[#stack + 1] = lib.make_error(caller, "Type", target)
							return true
						else
							stack[#stack + 1] = lib.make_integer(caller, inner)
							return true
						end
						return true
					end
				elseif cast.content.value == "float" then
					if type(target.content.value) == "table" then
						stack[#stack + 1] = lib.make_error(caller, "Type", target)
						return true
					else
						local inner = tonumber(target.content.value)
						if inner == nil then
							stack[#stack + 1] = lib.make_error(caller, "Type", target)
							return true
						else
							stack[#stack + 1] = lib.make_float(caller, inner)
							return true
						end
						return true
					end
				elseif cast.content.value == "error" then
					if type(target.content.value) == "table" then
						local inner = item.content.raw
						local v = lib.make_error(caller, inner, target)
						stack[#stack + 1] = v
						return true
					else
						local inner = tostring(target.content.value)
						local v = lib.make_error(caller, inner, target)
						stack[#stack + 1] = v
						return true
					end
				elseif cast.content.value == "expression" then
					if type(target.content.value) == "table" then
						stack[#stack + 1] = lib.make_error(caller, "Type", target)
						return true
					else
						local inner = tostring(target.content.value)
						local datum = {}
						datum['type'] = 'expression'
						datum['value'] = lib.parse(inner, target.chunk, target.line, target.char)
						datum['raw'] = target.content.raw

						local token = {}
						for k, v in pairs(target) do
							token[k] = v
						end
						token['content'] = datum

						stack[#stack + 1] = token
						return true
					end
				elseif cast.content.value == "interrupt" then
					stack[#stack + 1] = lib.make_error(caller, "Type", target)
					return true
				elseif cast.content.value == "foreign" then
					stack[#stack + 1] = lib.make_error(caller, "Type", target)
					return true
				else
					stack[#stack + 1] = lib.make_error(caller, "Type", target)
					return true
				end

				return false
			end,
			[[TODO]]
		)

		r['while'] = lib.make_builtin('while', 'stdlib',
			function(caller, env, stack)
				local check = table.remove(stack, #stack)
				local body = table.remove(stack, #stack)

				if body.content.type ~= 'expression' then
					stack[#stack + 1] = lib.make_error(caller, "Type", body)
					return true
				end

				local check_value = false
				if check.content.type == 'expression' then
					local catch = {lib.eval(check.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end
				else
					stack[#stack + 1] = check
				end
				lib.cast_bool(caller, env, stack)
				local pop = table.remove(stack, #stack)
				check_value = pop.content.value == "true"

				while check_value do
					local catch = {lib.eval(body.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end

					check_value = false
					if check.content.type == 'expression' then
						local catch = {lib.eval(check.content.value, env, stack)}
						if not catch[1] then
							return false, catch[2]
						end
					else
						stack[#stack + 1] = check
					end
					lib.cast_bool(caller, env, stack)
					local pop = table.remove(stack, #stack)
					check_value = pop.content.value == "true"
				end

				return true
			end,
			[[Pops the body and check from the stack.
If the body is not an expression, then an error<Type> is pushed to the stack and the function returns.
If the check is an expression, it is evaluated, otherwise it is cast to bool like the `?` interrupt.
The body is then evaluated as an expression.
When the top of the stack is not `true` after a check and cast, the loop breaks.
Neither body nor check are evaluated in a new scope - their current environment persists.
]]
		)

		r['for'] = lib.make_builtin('for', 'stdlib',
			function(caller, env, stack)
				local range = table.remove(stack, #stack)
				local body = table.remove(stack, #stack)

				if range.content.type ~= 'expression' then
					stack[#stack+1] = lib.make_error(range, "Type", caller)
					return true
				elseif body.content.type ~= 'expression' then
					stack[#stack+1] = lib.make_error(range, "Type", caller)
					return true
				end

				local len = #env
				env[#env+1] = {}
				-- TODO: Should we bind target to env['self']...?
				local catch = {lib.eval(range.content.value, env, stack)}
				if not catch[1] then
					return false, catch[2]
				end
				while #env > len do
					table.remove(env, #env)
				end

				local name = table.remove(stack, #stack)
				local begin_pos = table.remove(stack, #stack)
				local end_pos = table.remove(stack, #stack)
				local increment = table.remove(stack, #stack) or make_integer(range, 1)

				if not end_pos then
					stack[#stack + 1] = lib.make_error(range, "Value")
					return true
				elseif not begin_pos then
					stack[#stack + 1] = lib.make_error(range, "Value")
					return true
				elseif not name then
					stack[#stack + 1] = lib.make_error(range, "Value")
					return true
				end

				local len = #env
				env[#env+1] = {}
				local check_len = #env
				env[#env][name.content.value] = begin_pos

				while true do
					local catch = {lib.eval(body.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end

					local installed = env[check_len][name.content.value]

					-- TODO: Use the add operator here instead.
					installed.content.value = (installed.content.value) + (increment.content.value)

					local current = lib.lookup(range, name, env)
					-- TODO: Use the equal operator here instead.
					if current.content.value == end_pos.content.value then
						break
					end
				end

				while #env > len do
					table.remove(env, #env)
				end

				return true
			end,
			[[Pops two expressions from the stack.
The first should be the range.
The second, the loop body.
If either is not an expression a error<Type> is pushed and the function returns.

The range expression should push:
The increment to add to the check value each time.
	Defaults to i1 if not given.
The end target for the check value.
	If not given, a error<Value> is pushed instead.
The start value for the check value.
	If not given, a error<Value> is pushed instead.
The name to bind the check value into the environment.
	If not given, a error<Value> is pushed instead.

The values of the range probably should be integers
for most uses - but it is not a requirement.

After executing the body, the increment is installed
into the originally installed scope.
That is, if you bind a new symbol with a new value,
no increment will occur, and that value will be taken instead.]]
		)

		r['foreach'] = lib.make_builtin('foreach', 'stdlib',
			function(caller, env, stack)
				local name = table.remove(stack, #stack)
				local list = table.remove(stack, #stack)
				local body = table.remove(stack, #stack)

				local len = #env
				env[#env+1] = {}

				local args = {}
				local catch = {lib.eval(list.content.value, env, args)}
				if not catch[1] then
					return false, catch[2]
				end

				for idx, cell in ipairs(args) do
					env[#env][name.content.value] = cell

					local catch = {lib.eval(body.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end
				end

				while #env > len do
					table.remove(env, #env)
				end

				return true
			end,
			[[TODO]]
		)

		r['if'] = lib.make_builtin('if', 'stdlib',
			function(caller, env, stack)
				local check = table.remove(stack, #stack)
				local check_body = table.remove(stack, #stack)
				if not check_body or check_body.content.type ~= 'expression' then
					stack[#stack + 1] = lib.make_error(check_body or caller, "Type", caller)
					return true
				end

				local else_body = false
				if stack[#stack] and stack[#stack].content.type == "symbol" and stack[#stack].content.value == "else" then
					local tmp_else = table.remove(stack, #stack)
					else_body = table.remove(stack, #stack)

					if not else_body or else_body.content.type ~= 'expression' then
						stack[#stack + 1] = lib.make_error(tmp_else, "Type", caller)
						return true
					end
				end

				local len = #env
				env[#env+1] = {}

				local catch = {lib.eval(check.content.value, env, stack)}
				if not catch[1] then
					return false, catch[2]
				end
				lib.cast_bool(caller, env, stack)
				local pop = table.remove(stack, #stack)
				check_value = pop.content.value == "true"

				if check_value then
					local catch = {lib.eval(check_body.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end
				elseif else_body then
					local catch = {lib.eval(else_body.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end
				end

				while #env > len do
					table.remove(env, #env)
				end

				return true
			end,
			[[Takes an expression from the top of the stack to evaluate.
The result of that, cast to bool like the `?` interrupt, is used to decide what next to evaluate.
If the symbol of `true`, then the next expression is evaluated.
If not `true`, and the top of the stack is the symbol `else`, then that symbol and a following expression are popped.
The expression is then evaluated.

`else` is *optional*.
This only allows for a single branch. If you need to process more, then look at `cond`.

If the expected expressions are of a different type, pushes an error<Type>.
]]
		)

		r['cond'] = lib.make_builtin('cond', 'stdlib',
			function(caller, env, stack)
				local list = table.remove(stack, #stack)
				if not list or not list.content.type == 'expression' then
					stack[#stack + 1] = lib.make_error(list or caller, "Type", caller)
					return true
				end

				local check_list = list.content.value
				for i=1, #check_list, 2 do
					local expr_check = check_list[i+1]
					local expr_body = check_list[i]

					local len = #env
					env[#env+1] = {}

					local catch = {lib.eval(expr_check.content.value, env, stack)}
					if not catch[1] then
						return false, catch[2]
					end
					lib.cast_bool(caller, env, stack)
					local pop = table.remove(stack, #stack)
					check_value = pop.content.value == "true"

					if check_value then
						local catch = {lib.eval(expr_body.content.value, env, stack)}
						if not catch[1] then
							return false, catch[2]
						end

						while #env > len do
							table.remove(env, #env)
						end

						return true
					end

					while #env > len do
						table.remove(env, #env)
					end
				end

				return true
			end,
			[[Pops a single expression from the stack.
If not an expression, push an error<Type>.
Otherwise, iterates over the expression in pairs.
Evaluating one half of the pair, and casting to bool like the `?` interrupt, if it is `true`,
evaluates the other half of the pair and returns.
Otherwise continues to the next.
e.g.

cond! {
	{false} {print! "Nope."}
	{true} {print! Here}
}

]]
		)

		r['reverse'] = lib.make_builtin('reverse', 'stdlib',
			function(caller, env, stack)
				local target = table.remove(stack, #stack)
				if not target or target.content.type ~= 'expression' then
					return true
				end

				local new_value = {}
				for i=#target.content.value, 1, -1 do
					new_value[#new_value + 1] = target.content.value[i]
				end
				
				local s = lib.parse("{}")
				if not s or not s[1] then
					return false
				end
				
				local new_wrap = s[1]
				for k, v in pairs(target) do
					new_wrap[k] = v
				end
				for k, v in pairs(target.content) do
					new_wrap.content[k] = v
				end
				new_wrap.content.value = new_value

				stack[#stack + 1] = new_wrap

				return true
			end,
			[[Reverses the order of an expression.
If given nothing or a non-expression, acts as a no-op.]]
		)

		return r
	end

	lib.make_nil = function(caller)
		local token = {}
		local caller = caller or {}
		caller.content = caller.content or {}
		for k, v in pairs(caller) do
			token[k] = v
		end
		token.content = {}
		for k, v in pairs(caller.content) do
			token.content[k] = v
		end
		token.content.type = "symbol"
		token.content.value = "nil"

		return token
	end

	lib.make_integer = function(caller, value)
		local token = {}
		local caller = caller or {}
		caller.content = caller.content or {}
		for k, v in pairs(caller) do
			token[k] = v
		end
		token.content = {}
		for k, v in pairs(caller.content) do
			token.content[k] = v
		end
		token.content.type = "integer"
		token.content.value = math.floor(tonumber(value) or 0)

		return token
	end

	lib.make_float = function(caller, value)
		local token = {}
		local caller = caller or {}
		caller.content = caller.content or {}
		for k, v in pairs(caller) do
			token[k] = v
		end
		token.content = {}
		for k, v in pairs(caller.content) do
			token.content[k] = v
		end
		token.content.type = "float"
		token.content.value = tonumber(value) or 0.0

		return token
	end

	lib.make_symbol = function(caller, value)
		local token = {}
		local caller = caller or {}
		caller.content = caller.content or {}
		for k, v in pairs(caller) do
			token[k] = v
		end
		token.content = {}
		for k, v in pairs(caller.content) do
			token.content[k] = v
		end
		token.content.type = "symbol"
		token.content.value = tostring(value) or ""

		return token
	end

	lib.make_foreign = function(caller, value)
		local token = {}
		local caller = caller or {}
		caller.content = caller.content or {}
		for k, v in pairs(caller) do
			token[k] = v
		end
		token.content = {}
		for k, v in pairs(caller.content) do
			token.content[k] = v
		end
		token.content.type = "foreign"
		token.content.value = value

		return token
	end

	lib.make_error = function(caller, msg, trace)
		local token = {}
		local caller = caller or {}
		caller.content = caller.content or {}
		for k, v in pairs(caller) do
			token[k] = v
		end
		token.content = {}
		for k, v in pairs(caller.content) do
			token.content[k] = v
		end
		token.content.type = "error"
		token.content.value = msg
		token.content.extra = trace

		return token
	end

	lib.make_string = function(caller, msg)
		local token = {}
		local caller = caller or {}
		caller.content = caller.content or {}
		for k, v in pairs(caller) do
			token[k] = v
		end
		token.content = {}
		for k, v in pairs(caller.content) do
			token.content[k] = v
		end
		token.content.type = "string"
		token.content.value = tostring(msg or "")

		return token
	end

	lib.lookup = function(caller, target, env)
		for i=#env, 1, -1 do
			local environ = env[i]
			if environ[target.content.value] ~= nil then
				return environ[target.content.value]
			end
		end

		return lib.make_nil(caller)
	end

	lib.cast_bool = function(caller, env, stack)
		local target = table.remove(stack, #stack) or lib.make_symbol(caller, "false")
		if target.content.type == "symbol" then
			if target.content.value == "nil" or target.content.value == "false" then
				stack[#stack + 1] = lib.make_symbol(caller, "false")
				return true
			else
				stack[#stack + 1] = lib.make_symbol(caller, "true")
				return true
			end
		elseif target.content.type == "error" then
			stack[#stack + 1] = lib.make_symbol(caller, "false")
			return true
		else
			stack[#stack + 1] = lib.make_symbol(caller, "true")
			return true
		end
	end

	lib.exec = function(caller, env, stack)
		local target = table.remove(stack, #stack)
		if target then
			if target.content.type == "expression" then
				local len = #env
				env[#env+1] = {}
				-- TODO: Should we bind target to env['self']...?
				local catch = {lib.eval(target.content.value, env, stack)}
				if not catch[1] then
					return false, catch[2]
				end
				while #env > len do
					table.remove(env, #env)
				end
			elseif target.content.type == "symbol" then
				local v = lib.lookup(caller, target, env) or lib.make_nil(caller)
				if v.content.type == "symbol" and v.content.value == "nil" then
					return false, lib.make_error(caller, "Critical", target)
				end
				stack[#stack + 1] = v

				local catch = {lib.exec(caller, env, stack)}
				if not catch[1] then
					return false, catch[2]
				end
			elseif target.content.type == "builtin" then
				local catch = {target.content.value(caller, env, stack)}
				if not catch[1] then
					local e = catch[2] or lib.make_error(caller, "Critical", target)
					return false, e
				end
			else
				-- Type Error:
				local e = lib.make_error(caller, "Type", target)
				stack[#stack + 1] = e
			end
		end
		return true
	end

	lib.eval = function(tree, env, stack)
		local env = env or {}
		local stack = stack or {}
		for i=1, #tree do
			if tree[i].content.type == "interrupt" and tree[i].content.value == '$' then
				local target = table.remove(stack, #stack)
				if not target then
					stack[#stack + 1] = lib.make_nil(caller)
					return true
				end
				local v = lib.lookup(tree[i], target, env) or lib.make_nil(tree[i])
				stack[#stack + 1] = v
			elseif tree[i].content.type == "interrupt" then
				local catch = {lib.exec(tree[i], env, stack)}
				if not catch[1] then
					return false, catch[2]
				end
				if stack[#stack] and stack[#stack].content.type == "error" and stack[#stack].content.value == "Critical" then
					return false, stack[#stack]
				elseif tree[i].content.value == '?' then
					-- Cast to boolean.
					lib.cast_bool(tree[i], env, stack)
				end
			else
				stack[#stack + 1] = tree[i]
			end
		end
		return true
	end

	-- TODO: argparse
	-- TODO: repl (with hints, completions, etc.)

	if debug and (debug.getinfo(3) == nil) then
		local environ = {}
		if os.getenv then
			setmetatable(environ, {
				__index = function(self, k)
					local w = os.getenv(k)
					if w then
						return lib.make_string(nil, w)
					else
						return lib.make_nil(nil)
					end
				end
			})
		end

		local arg = arg or {}
		for idx, argument in ipairs(arg) do
			if idx > 0 then
				local f = io.open(argument)
				local r = {lib.eval(lib.parse(f:read("*all"), argument), {environ, lib.stdlib()})}
				f:close()
				if not r[1] then
					if type(r[2]) == "table" then
						io.stderr:write(lib.tostring(r[2]) .. "\n")
						os.exit(1)
					end
				end
			end
		end
	end

	return lib
end

-- TODO: When bubbling a critical error, the traceback "extra" should turn into a list,
-- so it's an actual traceback.
