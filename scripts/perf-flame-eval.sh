#!/usr/bin/env bash

fen=$1

zig build -Doptimize=ReleaseFast

sudo perf record -F 99 -a -g -- \
    ./zig-out/bin/ziggurat eval 20 "$fen"
sudo perf script > out.perf
stackcollapse-perf.pl out.perf > out.folded
flamegraph.pl out.folded > out.svg
zen-broser out.svg
