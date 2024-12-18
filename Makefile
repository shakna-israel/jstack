ifdef EXTRA_TARGET
TARGETS+=$(EXTRA_TARGET)
endif
TARGETS+=luajit
TARGETS+=lua5.4
TARGETS+=lua5.3
TARGETS+=lua5.2
TARGETS+=lua5.1

test: $(TARGETS)

luajit:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -P$(shell nproc) -t $@

lua5.4:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -P$(shell nproc) -t $@

lua5.3:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -P$(shell nproc) -t $@

lua5.2:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -P$(shell nproc) -t $@

lua5.1:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -P$(shell nproc) -t $@

$(EXTRA_TARGET):
	#Luau has a different require preference, so we'll just cp the file where it expects:
	echo "tests/stdlib/ tests/lib/" | xargs -n 1 cp -v jstack.lua
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -P$(shell nproc) -t /$@
	rm tests/*/jstack.lua

install: jstack.lua
	/usr/bin/install -m 755 -T jstack.lua /usr/local/bin/jstack

# TODO: Can we build and test against https://github.com/whitecatboard/Lua-RTOS-ESP32 ??
