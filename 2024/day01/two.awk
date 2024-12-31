#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 2) { aoc::data_error() }
{
    ++left[0 + $1]
    ++right[0 + $2]
}
END {
    for (i in left) {
        total += i * left[i] * (0 + right[i])
    }
    print total
}
