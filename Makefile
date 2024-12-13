ifdef EXTRA_TARGET
TARGETS+=$(EXTRA_TARGET)
endif
TARGETS+=luajit
TARGETS+=lua5.4
TARGETS+=lua5.3
TARGETS+=lua5.2
TARGETS+=lua5.1

test: $(TARGETS)
	echo $(TARGETS)

luajit:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -t $@

lua5.4:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -t $@

lua5.3:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -t $@

lua5.2:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -t $@

lua5.1:
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -t $@

$(EXTRA_TARGET):
	find tests -depth -type f -print0 | tr '\n' '\0' | xargs -0 -n1 -t /$@

install: jstack.lua
	/usr/bin/install -m 755 -T jstack.lua /usr/local/bin/jstack

# TODO: Can we build and test against https://github.com/whitecatboard/Lua-RTOS-ESP32 ??
