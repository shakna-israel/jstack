# Environments & The Stack

## Environments

`jstack` is a scoped language. Whenever you trigger an interrupt, you will be creating a new environment. This means that whilst you can create new bindings, when that environment is eventually removed, that binding will go with it.

This tends to be referred to as *lexical scoping* - however `jstack` is not precisely lexically scoped. You are given the power, in the `stdenv` library, to violate such scoping rules.

	let: x i21
	print: x$

	:{
		let: x i12
		:{
			let: x i6
			print: x$
		}
		print: x$
	}

	print: x$

	> 21
	> 6
	> 12
	> 21

The evaluation process only maintains a *count* of environments, to keep the balanced. With the `stdenv` library, you can reach out and change particular environments and can expect results to persist, so long as the *count* remains sensible. This takes the place of traditional macro systems in other systems, such as Scheme's `let-*values` forms. Though such environmental manipulation is needed less, as an expression can be manipulated without the need of any macro.

## The Stack

The stack is the main piece of memory in `jstack`. All values are pushed onto the top of the stack, and then later extracted from it.

The stack is a First-In-First-Out style of stack, a common architecture found across many programming languages and utility libraries.

Everything you do will involve manipulating the stack in some form or another.

\vspace*{\fill}

\pagebreak
