# Examples

It's often helpful when getting to grips with a new language, just to see it in practice.

---

## Fahrenheit/Celsius Conversion

Given the formula, `fahrenheit = celsius * 1.8 + 32`, we can easily generate two expressions, for shifting between the two temperature measures:

	let: fahrenheit->celsius {
		; celsius = (fahrenheit - 32) / 1.8
		assert: dupe: to: float
		-: swap: f32
		/: swap: f1.8
	}
	print: fahrenheit->celsius: f71.6

	let: celsius->fahrenheit {
		; fahrenheit = (celsius * 1.8) + 32
		assert: dupe: to: float
		*: swap: f1.8
		+: f32
	}
	print: celsius->fahrenheit: f22

We have to put things on the right side of the multiply and divide. A little `swap` can do that for us.

However, we could also do that by binding to our local environment:

	let: fahrenheit->celsius {
		; celsius = (fahrenheit - 32) / 1.8
		assert: dupe: to: float
		let: a

		let: a -: a$ f32
		/: a$ f1.8
	}
	print: fahrenheit->celsius: f71.6

	let: celsius->fahrenheit {
		; fahrenheit = (celsius * 1.8) + 32
		assert: dupe: to: float
		let: a

		*: a$ f1.8
		+: f32
	}
	print: celsius->fahrenheit: f22

The underlying idea of the expressions is extremely similar. So we could just go ahead and generate one, from the other.

TODO: Generate example with stdexpression

---

TODO: Some standard example code

\vspace*{\fill}

\pagebreak
