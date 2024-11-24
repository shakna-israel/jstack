#!/bin/sh

ag todo --count | awk -F':' '{print $2}' | paste -sd+ | bc
