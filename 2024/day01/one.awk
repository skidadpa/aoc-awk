#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 2) { aoc::data_error() }
{
    left[NR] = 0 + $1
    right[NR] = 0 + $2
}
END {
    n = asort(left)
    asort(right)
    for (i = 1; i <= n; ++i) {
        total += aoc::abs(left[i] - right[i])
    }
    print total
}
