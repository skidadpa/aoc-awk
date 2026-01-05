#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
/^Filesystem +Size +Used +Avail +Use%$/ {
    output_started = 1
    next
}
!output_started {
    next
}
(NF != 6) {
    aoc::data_error("invalid output")
}
{
    if ($4 + $5 != $3) {
        aoc::data_error("sizes don't match")
    }
    SIZE[$1,$2] = $3
    USED[$1,$2] = $4
    AVAIL[$1,$2] = $5
}
END {
    num_pairs = 0
    for (A in USED) if (USED[A]) {
        for (B in AVAIL) if (B != A) {
            if (USED[A] <= AVAIL[B]) {
                ++num_pairs
            }
        }
    }
    print num_pairs
}
