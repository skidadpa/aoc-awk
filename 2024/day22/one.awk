#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    NUM_STEPS = 2000
}
$0 !~ /^[[:digit:]]+$/ {
    aoc::data_error()
}
{
    number = 0 + $0
    for (i = 1; i <= NUM_STEPS; ++i) {
        number = and(xor(number, number * 64), 16777215)
        number = and(xor(number, rshift(number, 5)), 16777215)
        number = and(xor(number, number * 2048), 16777215)
    }
    if (DEBUG) {
        printf("%d: %d\n", $0, number)
    }
    sum += number
}
END {
    print sum
}
