#!/bin/bash

set -ex

if [ ! -z "$(git show-ref --tags)" ]; then
	mkdir build
	cp jstack.lua build/
	tar -czvf 'jstack-release.tar.gz' build
fi
