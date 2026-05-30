#!/usr/bin/env bash

run_test() {
    file=$1
    echo "$1"
    zig test "src/$1.zig"
    echo ""
}

tests=(
    "chess/bitboard"
    "chess/square"
    "chess/board"
    "chess/movelist"
    "perft"
    "engine"
)

for test in "${tests[@]}"; do
    run_test "$test"
done
