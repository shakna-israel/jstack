# jstack

An easy to use, stack-based, programming language.

---

## Hello World

	print! "Hello, World!"

The parser is right-to-left on lines, and exclamations jump one to the left, making it easier to read.

Meaning that the above is functionally equivalent to:

	"Hello, World!" ; Push a string to the stack.
	print ; Push a symbol.
	! ; Lookup and call the symbol from the environment.

---

## Examples

A lot of examples exist and can be found in the `examples` directory.

However, [learnxinyminutes.stk](examples/learnxinyminutes.stk) is probably the best starting point.

Then the [import_lua.stk](examples/import_lua.stk) example is probably worth a visit, to see the cross-language interop that allows you to use the entire Lua ecosystem.

---

## License

3-Clause BSD, as of writing. See [LICENSE.md](LICENSE.md) for legally binding text.

---

## Dependencies

`jstack` should run on any Lua 5.1+ system. (Tested on 5.1, 5.2, 5.3, 5.4, and luajit).

I would recommend `luajit 2.0` or above, however most should work fine.

Example, for Debian-based systems:

	apt install luajit

### Note on Luau:

Whilst `jstack` does run under Luau, that platform is designed to intentionally lack filesystem and C-module access. This means that the resulting `jstack` will also lack those. It won't be able to import most files - only Lua ones.

---

## Install

If you have the dependencies in place, and are running a \*nix based system, simply:

	make install

(Hint: If you get a permission error, you probably need to run as `root`.)

---

## Testing

[![builds.sr.ht status](https://builds.sr.ht/~shakna/jstack.svg)](https://builds.sr.ht/~shakna/jstack?)

[Bug Reports](https://todo.sr.ht/~shakna/jstack).

To run the testsuite, from a \*nix platform, run `make`.

	make -j4

This just runs several versions of Lua against the entire `tests` directory.

We *don't* test the `examples` directory: Some of those files are designed to show crashes.

You will need:

* find (POSIX standard)

* xargs (GNU)

* luajit (preferably Luajit 2.0)

* lua5.4 (PUC)

* lua5.3 (PUC)

* lua5.2 (PUC)

* lua5.1 (PUC)
