#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "x"
}
(NF != 3) { aoc::data_error() }
{
    side[1] = $1 + $2; side[2] = $2 + $3; side[3] = $3 + $1
    len = 9999999999
    for (i in side) if (2 * side[i] < len) len = 2 * side[i]
    len += $1 * $2 * $3
    total += len
}
END {
    print total
}
