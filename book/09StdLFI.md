# stdlfi

The `stdlfi` library (the Standard Lua Foreign Interface) is an optional library,
that should appear if `jstack` is hosted by Lua,
to allow interop between the two, from `jstack`'s side of the equation.

## Warning

The moment that you import this library, any sense of sandbox is violated. It allows access to the host language,
which means that programs can now break into and modify the interpreter, if they so wish.

With great power, comes super cow powers.

If you are developing a program were security is held to be a premium, then the easiest thing is to ban the
use of this library, both yourself and all dependencies. Keep the sandbox intact.

***All LFI functions are inherently unsafe.***

Here there be dragons.

---

## Introp with Lua

Generally speaking, you will be able to seamlessly interoperate with the Lua runtime,
*without* reaching for this library.

Instead, this library stands to fill the gap where the two programming paradigms are irreconcilable.

Such as being able to install value into the Lua environment, rather than simply passing arguments via the stack.
`Love2D`, for example, expects this when creating callback functions.

---

\vspace*{\fill}

\pagebreak

## `stdlfi.tofunction`

Being able to convert anythin `jstack` into a Lua-native function, or at least a wrapper, can make interop with a vast number of Lua utilities and libraries far, far, easier.

This builtin pops a single value from the stack.

If the value is an expression:

* Pushes a foreign function that evaluates the expression, using the argument list as a stack, and then unpacks and returns the stack.

	* This uses a reference at call time - it is not copied!

If the value is not an expression:

* Pushes a foreign function that returns that value.

	* This uses a reference at call time - it is not copied!

e.g.

	assert: import: stdlfi

	let: x {
		print: "Hello, World!"
	}

	let: lua_f stdlift.tofunction: x$
	print: type: lua_f$

	> `foreign`

## `stdlfi._G`

TODO

## `stdlfi.get`

TODO

## `stdlfi.set`

TODO

## `stdlfi.type`

TODO

\vspace*{\fill}

\pagebreak
