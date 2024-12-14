# The Standard Library

As `jstack` has no builtin or reserved statements, all basic operations require a call to the standard libary.

The standard library can *also* be imported as `stdlib`.

## stdlib.nop

When called, `nop` does exactly nothing.

It is the "No Operation" builtin. Somewhat equivalent to `pass` in Python or `nop` in ASM.

e.g.

	nop!

Whilst you often will have no use for this, swapping it in and out of expressions, when manipulating expressions at runtime, is one of the clearer use-cases.

TODO: example

## stdlib.help

Pops one from stack.

If a symbol, looks up from current environment. If no symbol is given, or is not a symbol, then a `nil` symbol will be used instead.

Finally, it pushes a string containing any help information for the given item to the stack.

The exact format of the help information is *not guaranteed* - it is designed for human eyes, not automation.

e.g.

	print: help: print$
	> Pops the top most item from the stack.
	> If none, treats it as an empty string.
	> Converts the item to a string, and prints it to stdout.
	> Appends a newline to the end of the output.
	> [builtin] <stdlib::>
	> <stdlib.print>

## stdlib.let

Takes the name, and then value, from the top of the stack.

Then binds it into the current environment.

e.g.

	let: name "James"
	print: name$
	> James

## stdlib.get

Functionally equivalent to the `$` interrupt.

Pops one symbol from the stack, and finds the currently linked value from the environment.

If nothing is found, pushes a `nil` symbol.

e.g.

	let: name "James"
	get: name
	print!
	> James

	print: get: blahgah
	> `nil`

## stdlib.clear

Drops the entire stack.

e.g.

	print: `nil`
	> `thing`
	
	print: clear: `nil`
	>

## stdlib.dupe

This copies the top item from the stack and places a second `reference` to it on the stack.

This is somewhat akin to a pointer in other languages. The two items are functionally the same. Modify one, and both will be.

See also, `copy`.

e.g.

	TODO

## stdlib.copy

This copies the top item from the stack and places a second value to it on the stack. This is a `copy`. The two items do not point to each other, and no longer have anything in common whatsoever.

See also, `dupe`.

e.g.

	TODO

## stdlib.assert

The top value on the stack is popped.

If the stack is empty, or the top value was an error, then an `error<Critical>` is thrown.

e.g.

	assert: import: thing
	> error<error<Import>(tmp.stk 1:15)
	> :
	> `thing`>(tmp.stk 1:15)
	> :

	clear!
	assert!
	> error<Critical>(tmp.stk 2:7)
	> !


## stdlib.print

TODO

## stdlib.for

TODO

## stdlib.reverse

TODO

## stdlib.foreach

TODO

## stdlib.if

TODO

## stdlib.cond

TODO

## stdlib.while

TODO

## stdlib.is

TODO

## stdlib.to

TODO

## stdlib.drop

TODO

## stdlib.swap

TODO

## stdlib.equal

TODO

## stdlib.type

TODO

## stdlib.describe

TODO

## stdlib.import

TODO

## stdlib.not

TODO

## stdlib.not-equal

TODO

## stdlib.or

TODO

## stdlib.less-than

TODO

## stdlib.less-than-equal

TODO

## stdlib.greater-than

TODO

## stdlib.greater-than-equal

TODO

\vspace*{\fill}

\pagebreak
