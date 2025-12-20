#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]"
    sum = 0
    DEBUG = 0
}
(NF < 1) {
    aoc::data_error()
}
{
    num = $1 $NF
    sum += num
    if (DEBUG) {
        printf("%s contains %d tokens:", $0, NF)
        for (p = 1; p <= NF; ++p) printf(" %s", $p)
        printf(" => %s\n", num)
    }
}
END {
    print sum
}
