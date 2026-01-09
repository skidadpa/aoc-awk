#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FACTOR["A"] = 16807
    FACTOR["B"] = 48271
    DIVISOR = 2147483647
    BIT_MASK = 65535
    DFILE = "debug.txt"
}
$0 !~ /^Generator [AB] starts with [[:digit:]]+$/ {
    aoc::data_error()
}
{
    VALUE[$2] = $5
}
END {
    if (length(VALUE) != 2) {
        aoc::data_error("did not get starting values for both generators")
    }
    match_count = 0
    for (i = 1; i <= 40000000; ++i) {
        low_bits = 0
        for (v in VALUE) {
            VALUE[v] *= FACTOR[v]
            VALUE[v] %= DIVISOR
            low_bits = xor(low_bits, and(VALUE[v], BIT_MASK))
        }
        if (low_bits == 0) {
            if (DEBUG) {
                print i, ":", VALUE["A"], "(" and(VALUE["A"], BIT_MASK) ") and", VALUE["B"], "(" and(VALUE["B"], BIT_MASK) ") match" > DFILE
            }
            ++match_count
        }
    }
    print match_count
}
