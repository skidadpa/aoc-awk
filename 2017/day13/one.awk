#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
$0 !~ /^[[:digit:]]+: [[:digit:]]+$/ {
    aoc::data_error()
}
{
    POSITION[$1] = 0
    DEPTH[$1] = $2
    DIRECTION[$1] = 1
    if (max_range < $1) {
        max_range = $1
    }
}
END {
    severity = 0
    for (range = 0; range <= max_range; ++range) {
        if ((range in POSITION) && (POSITION[range] == 0)) {
            severity += (range * DEPTH[range])
        }
        for (p in POSITION) {
            POSITION[p] += DIRECTION[p]
            if ((POSITION[p] + 1) == DEPTH[p]) {
                DIRECTION[p] = -1
            } else if (POSITION[p] == 0) {
                DIRECTION[p] = 1
            }
        }
    }
    print severity
}
