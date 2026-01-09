#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FACTOR["A"] = 16807
    FACTOR["B"] = 48271
    MASK["A"] = 3
    MASK["B"] = 7
    DIVISOR = 2147483647
    BIT_MASK = 65535
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
    # Too many lookups to do all of the calculations on arrays...
    a = VALUE["A"]
    fa = FACTOR["A"]
    ma = MASK["A"]
    b = VALUE["B"]
    fb = FACTOR["B"]
    mb = MASK["B"]
    match_count = 0
    for (i = 1; i <= 5000000; ++i) {
        if ((DEBUG > 1) && (i % 100000 == 0)) {
            print i > DFILE
        }
        do {
            a = (a * fa) % DIVISOR
        } while ((a % 4) != 0)
        do {
            b = (b * fb) % DIVISOR
        } while ((b % 8) != 0)
        if (and(a, BIT_MASK) == and(b, BIT_MASK)) {
            if (DEBUG) {
                printf "%d : %x and %x match\n", i, a, b > DFILE
            }
            ++match_count
        }
    }
    print match_count
}
