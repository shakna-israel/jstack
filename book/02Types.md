# Types

`jstack`, is a dynamic language. That means that variables, or its equivalent, do not have types,
rather each object has its own type. A value has a type, and it carries it with it. There are only a limited number of types - new ones cannot be created. An object-oriented paradigm is not followed, though one can conceivably be implemented.

The types of `jstack` are:

* symbol

* string

* integer

* float

* expression

* builtin

* error

* interrupt

* foreign

This should feel a little different than many languages, almost immediately. If you have some
experience with Lisp, you'll know the symbol and it's purpose - and why that means there are no
booleans here.

\vspace*{\fill}

\pagebreak

## Symbols

A symbol is a value that is equal to itself and no other. A "bare word" is a symbol, but you may also define one with a backtick, or percentage, as quote.

Rather than having a specific type for it, when an expression pushes a truth-y or false-y value to
the stack in `jstack`, it will likely be a symbol of `nil`, `true` or `false`. There is no nil, NULL, etc.
There is no true or false.

e.g.
	bareword_symbol

	`symbol with breaks in it`

	%This is also a single symbol.%

	equal: thing `thing`

\vspace*{\fill}

\pagebreak

## Strings

Strings are simply groups of bytes. There is no encoding understood. Whilst the underlying implementation
may or may not be an array of bytes, it can be understood as one by the programmer.

They are marked by `"..."`, `'...'`, or `[...]`.

e.g.

	'This is a string.'

	"Also a string."

	[Yet another string.]

### Escaping

Characters within a string may be escaped by prefixing the character with `\`.

There are a number of specific escapes as well.

The escape sequence, `\xDD` allows you to generate characters via hex encoding. i.e. `"\x0A"` contains a newline.

The escape sequence, `\DDD` allows you to generate characters via a decimal encoding. i.e. `"\010"` contains a newline.

The escape sequence, `\a` is equal to the ASCII BEL character.

The escape sequence, `\b` is equal to the ASCII BS or "backspace" character.

The escape sequence, `\f` is equal to the ASCII LF of "line feed" character.

The escape sequence, `\n` is equal to the ASCII NL or "new line" character.

The escape sequence, `\r` is equal to the ASCII CR or "carriage return" character.

The escape sequence, `\t` is equal to the ASCII HT, or "horizontal tab" character.

The escape sequence, `\v` is equal to the ASCII VT, or "vertical tab" character.

In the case of a less specific escape, the character is equal to itself. i.e. `"\""` contains a double quote.

\vspace*{\fill}

\pagebreak

## Integers

An integer can be understood as a whole number.

The exact size of the integer depends on the host Lua implementation. It varies widely, as Lua may
run across a variety of systems, including microprocessing units. On some units, integers may be
emulated by floats - which may cause rounding concerns.

Unlike Lua, `jstack`'s floats and integers are *not* interchangeable.

Integers are marked by an `i`, an optional `+` or `-`, followed by units of 0 to 9.

One marked by `+` is positive, and `-` is negative, with the absent being positive.

All operations returning an integer, will *round down*, where you might expect them to have some remainder.
That is, you can expect things such as floor division to be used.

e.g.

	i21

	i+21

	i-21

	/: i3 i2
	equal: i1

\vspace*{\fill}

\pagebreak

## Floats

A float can be understood as a floating point number. This is not a decimal, and naively treating it
as one will cause issues.

The exact size of the float depends on the host Lua implementation. It varies widely, as Lua may
run across a variety of systems, including microprocessing units. Not all systems will have a
dedicated FPU, and that may cause performance concerns.

Unlike Lua, `jstack`'s floats and integers are *not* interchangeable.

Floats are marked by an `f`, an optional `+` or `-`, followed by units of 0 - 9, an optional `.` followed by units of 0 - 9.

One marked by `+` is positive, and `-` is negative, with the absent being positive.

e.g.

	f21

	f21.1

	f-21.1

\vspace*{\fill}

\pagebreak

## Expressions

Expressions are different than many languages. Careful understanding of them is essential for effectively programming
in `jstack`.

At their root, an expression is simply a list. Denoted by `{...}` or `(...)`, they contain values of every other kind, including interrupts.

When an interrupt is triggered with an expression at the head of the stack, then the expression is run as if it were
a program. This makes them functionally equivalent to the idea of a function or subroutine in other languages. When run, it receives its own environment, so that it acts is a relatively scoped way.

e.g.

	{
		print: "Hello."
	}
	!

However, expressions are *just* lists. They can be constructed, manipulated, and rearranged by other functions. There
is nothing 'special' about them at all.

Careful: The parser treats an expression as a single unit, so reading order is preserved. This means that some lists
may need to be reversed to preserve reading order:

	foreach: i {i3 i2 i1} {
		print: i$
	}

	> 1
	> 2
	> 3

Again, note here that the bracketed sections are just expressions. They are not special, and can be inserted onto the stack by any variety of things.

	let: check { equal? a$ b$ }

	if: check$ {
		print: "Equal!"
	}

This versatility means that `jstack` has no real need for macros, as anything that the language can process, can be constructed on the fly.

	assert: import: stdexpression
	let: x {}
	stdexpression.append: x$ "Hello, World!"
	stdexpression.append: x$ print
	stdexpression.append: x$ to: interrupt "!"

	assert: is: expression x$
	x!

\vspace*{\fill}

\pagebreak

## Builtins

A builtin is a function constructed on the Lua side of things. They'll run just like an expression, but you won't be
able to inspect or modify them.

The standard libraries are supplied as builtins.

	print: type: print$
	> `builtin`

That is to say, a builtin is callable, but completely opaque. You don't get to manipulate them like an expression, but you will make extensive use of them.

\vspace*{\fill}

\pagebreak

## Errors

An error type is it's own opaque type.

Each error carries a traceback, and it's own subtype with it.

Generally speaking, it is displayed as `error<...>` where `...` is the subtype.

Various subtypes are common and appear throughout the standard libraries, such as `error<Type>`.

However, the `error<Critical>` is treated different than the rest - if it is on the top of the stack after some evaluation is finished, then the interpreter ceases processing and attempts to exit.

Such errors *can* be caught by the `stderror` library, and *must* be, unless you want to crash.

	stderror.catch: {
		stderror.throw: Critical
	} error {
		print: "Caught:"
		print: error$
	}

\vspace*{\fill}

\pagebreak

## Interrupts

An interrupt may appear as a suffix on some symbol, in which case they precede the symbol, or on their own.

When an interrupt is hit during evaluation, it triggers some kind of event.

Generally speaking, that means `!` for calling a builtin or expression, or `?` to do the same - but turn the result into a `true` or `false` symbol.

There are four interrupts:

* `!` - An item is popped from the stack. If it is a symbol, it first triggers `$` and then continues. The `!` interrupt runs an evaluation of a builtin or expression. Receiving anything else, it generates an `error<Type>`.

* `:` - This interrupt is just an alias for `!`.

* `?` - This interrupt is useful for conditionals. This interrupt first triggers `!`, and then examines pops top value on the stack.

	* If the item is an error, a `false` symbol is pushed.

	* If the item is a `nil` symbol, a `false` symbol is pushed.

	* If the item is a `false` symbol, a `false` symbol is pushed.

	* Otherwise a `true` symbol is pushed.

* `$` - This interrupt pops a value from the stack, and then examines the environment. Looking from the bottom up, it finds the first matching value, and pushes that to the stack. If not values are found, it pushes a `nil` symbol.

\vspace*{\fill}

\pagebreak

## Foreign

A `foreign` type, is somewhat akin to `userdata` in Lua. It's something that comes from the host system, that `jstack`
knows absolutely nothing about. It is a type *not* managed by `jstack` directly, but some other infrastructure. It may as well be a void pointer.

\vspace*{\fill}

\pagebreak
