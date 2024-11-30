TARGETS+=luajit
TARGETS+=lua5.4
TARGETS+=lua5.3
TARGETS+=lua5.2
TARGETS+=lua5.1

test: $(TARGETS)

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
