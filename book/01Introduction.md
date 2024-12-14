# Introduction

	print: "Hello, World!"

`jstack` is a stack-based programming language, aimed at being both easy-to-read,
and flexible enough to step outside the norm. It utilises features that can make
it fall into the lazy, dynamically-typed, and strongly-typed categories.

It works by combining a simple syntax that can feel procedural, whilst maintaining
the features of other stack-based languages, such as Forth, allowing the difference
between code and data to disappear.

This flexibility allows the language to rewrite pieces of itself, whilst the syntax
aids in ensuring things don't become too unwieldy for the human putting things together.

`jstack` is implemented as both a runtime, and as a library for `Lua`. This makes it
easy to interop with, extendable with C, and all languages that bridge via C.

`jstack` has no sense of a `main` function to execute. In that way, it feels much like
most scripting languages - and that is the main purpose that it was designed for.

`jstack` is free software, and is provided with no guarantees, as stated in its license.

## Hello, World!

The definitive starting point for most newcomers to a language, is a tiny piece of example
code aimed at giving them a taste of the syntax. For better or worse, the one promoted by
K&R has endured.

	print: "Hello, World!"

The first taste of `jstack`'s syntax might leave you thinking that it feels a little like BASIC, Pascal,
or something else procedural. This is because the syntax *lies* to you. On purpose.

The above, can equally be written as:

	"Hello, World!"
	print
	:

That is, the string is pushed to the stack, then a symbol, and then a call is invoked.

`jstack`'s parser is complex, but the theory is simple. Rather than reading left to right, as in
a traditional stack-based language:

	"Hello, World" print :

It reads in the opposite direction. Each token is parsed right-to-left.
It breaks on lines - so long as the line is not within a string, and not within an expression.
It left-shifts interrupt calls - but only if appended to a token.

	print: "
	This string is printed."

Though we won't go into detail just yet, this "sometimes" breaking on a line, leads to an ALGOL-type
feel for expressions.

	if! { equal? a$ b$ } {
		print: Yay
	} else {
		print: Darn
	}

\vspace*{\fill}

\pagebreak
