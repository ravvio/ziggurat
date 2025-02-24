#!/usr/bin/env bash

zig build

sudo perf record -F 99 -a -g -- ./zig-out/bin/ziggurat
sudo perf script > out.perf
stackcollapse-perf.pl out.perf > out.folded
flamegraph.pl out.folded > out.svg
firefox out.svg
