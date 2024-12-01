# The Language

`jstack` is a line-oriented language. Whilst it may feel free-form, it is not. It break tokens on whitespace, unless the token may contain whitespace, and then breaks at the end of line, reverses the tokens, and places them into a flat tree.

The reserved words in `jstack` are:

* `!` - The `call` interrupt.

* `:` - Alias of `!`

* `?` - The `cast` interrupt.

* `$` - The `get` interrupt.

* `;` - Single line comments.

You may place any character not reserved, apart from `\n` (ASCII 10), `\t` (ASCII 9), `\r` (ASCII 13) or `\s` (ASCII 32) into an unquoted symbol. A quoted symbol may contain them, but will only be able to be referenced by another quoted symbol.

Quoted characters with special meaning are:

* `~...~` - For comments that are discarded by the parser.

* `{...}` - For expressions.

* `(...)` - For expressions.

* `"..."` - For strings.

* `'...'` - For strings.

* `[...]` - For strings.

* `%...%` - For symbols.

* `` `...` `` - For symbols.

Integers are marked by an `i`, an optional `+` or `-`, followed by units of 0 to 9.

Floats are marked by an `f`, an optional `+` or `-`, followed by units of 0 - 9, an optional `.` followed by units of 0 - 9.

For both a float and integer value, one marked by `+` is positive, and `-` is negative, with the absent being positive.

\vspace*{\fill}

\pagebreak
