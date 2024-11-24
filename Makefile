TARGETS+=luajit
TARGETS+=lua5.4
TARGETS+=lua5.3
TARGETS+=lua5.1

test: $(TARGETS)

luajit:
	find tests -depth -type f -exec echo $@ '{}' \; -exec $@ '{}' \; ;\

lua5.4:
	find tests -depth -type f -exec echo $@ '{}' \; -exec $@ '{}' \; ;\

lua5.3:
	find tests -depth -type f -exec echo $@ '{}' \; -exec $@ '{}' \; ;\

lua5.1:
	find tests -depth -type f -exec echo $@ '{}' \; -exec $@ '{}' \; ;\
