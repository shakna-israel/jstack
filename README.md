# jstack

An easy to use, stack-based, programming language.

---

## Hello World

	print! "Hello, World!"

The parser is right-to-left on lines, making it easier to read.

However, the above is functionally equivalent to:

	"Hello, World!"
	print
	!

Push a string to the stack.

Push a symbol.

Lookup and call the symbol from the environment.

---

## Examples

A lot of examples exist and can be found in the `examples` directory.

However, [learnxinyminutes.stk](examples/learnxinyminutes.stk) is probably the best starting point.

Then the [import_lua.stk](examples/import_lua.stk) example is probably worth a visit, to see the cross-language interop that allows you to use the entire Lua ecosystem.

---

## License

TODO

---

## Dependencies

`jstack` should run on any Lua 5.1+ system.

I would recommend `luajit 2.0` or above, however most should work fine.

Example, for Debian-based systems:

	apt install luajit

---

## Testing

To run the testsuite, from a \*nix platform, run `make`.

	make -j4

This just runs several versions of Lua against the entire `tests` directory.

We *don't* test the `examples` directory: Some of those files are designed to show crashes.

You will need:

* find (POSIX standard)

* luajit (preferably Luajit 2.0)

* lua5.4 (PUC)

* lua5.3 (PUC)

* lua5.1 (PUC)
