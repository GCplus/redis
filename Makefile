# 顶级 makefile，真正的shit在src/Makefile 里面

default: all

.DEFAULT:
	cd src && $(MAKE) $@

install:
	cd src && $(MAKE) $@

.PHONY: install
