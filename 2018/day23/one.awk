#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
    SELECTED = 1
}
$0 !~ /^pos=<-?[[:digit:]]+,-?[[:digit:]]+,-?[[:digit:]]+>, r=[[:digit:]]+$/ { aoc::data_error() }
{
    X[NR] = $1
    Y[NR] = $2
    Z[NR] = $3
    R[NR] = $4
    if (R[SELECTED] < R[NR]) {
        SELECTED = NR
    }
}
END {
    in_range = 0
    for (bot = 1; bot <= NR; ++bot) {
        if (aoc::manhattan(X[SELECTED],X[bot],Y[SELECTED],Y[bot],Z[SELECTED],Z[bot]) <= R[SELECTED]) {
            ++in_range
        }
    }
    print in_range
}
