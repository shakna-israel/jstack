# Error Handling

Error handling in `jstack` may be a little different than other languages.

Errors are just objects, which means that you push them to the stack, and you should be watching the stack on return to receive one - it won't just throw if you ignore it.

The exception being an `error<Critical>` which *will* attempt to trigger a crash.

Almost all error handling will be done by the `stderror` library, which will require you to import it.

The `stderror.catch` and `stderror.throw` builtins are probably the ones that you will be using.

	stderror.catch! {
		stderror.throw! Critical
	} error {
		print! "Caught."
		print error$
	}

See the `stderror` library section for more.

A common idiom on importing is:

	assert: import: "thing"

This causes `assert` to either consume the `true` symbol on success, or throw a `error<Critical>` if an `error<Import>` was pushed instead.

This allows you the freedom of optional imports where you may need them. Similar reasoning elsewhere is why errors don't, by default, throw. If you want or need it to throw - assert is your friend.

\vspace*{\fill}

\pagebreak
