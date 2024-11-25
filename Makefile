TARGETS+=luajit
TARGETS+=lua5.4
TARGETS+=lua5.3
TARGETS+=lua5.2
TARGETS+=lua5.1

test: $(TARGETS)

luajit:
	find tests -depth -type f -print0 | xargs -t -0L1 $@

lua5.4:
	find tests -depth -type f -print0 | xargs -t -0L1 $@

lua5.3:
	find tests -depth -type f -print0 | xargs -t -0L1 $@

lua5.2:
	find tests -depth -type f -print0 | xargs -t -0L1 $@

lua5.1:
	find tests -depth -type f -print0 | xargs -t -0L1 $@
