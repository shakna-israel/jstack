local jstack = require "./jstack"
assert(jstack)

assert(jstack.guess_filepath)
assert(type(jstack.guess_filepath) == "function")
assert(jstack.guess_filepath("./examples/hello1") == "./examples/hello1.stk")
assert(jstack.guess_filepath("./examples/scope") == "./examples/scope.stk")
