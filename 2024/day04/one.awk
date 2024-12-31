#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function count_matches(s,   f, b) { split(s, f, "XMAS")
                                    split(s, b, "SAMX")
                                    return length(f) + length(b) - 2 }
BEGIN {
    FS = ""
}
{
    VERTICAL[NR] = $0
    for (i = 1; i <= NF; ++i) {
        HORIZONTAL[i] = HORIZONTAL[i] $i
        LEFT_DIAG[NF - NR + i] = LEFT_DIAG[NF - NR + i] $i
        RIGHT_DIAG[NR - 1 + i] = $i RIGHT_DIAG[NR - 1 + i] 
    }
}
END {
    for (i in VERTICAL) {
        matches += count_matches(VERTICAL[i])
    }
    for (i in HORIZONTAL) {
        matches += count_matches(HORIZONTAL[i])
    }
    for (i in LEFT_DIAG) {
        matches += count_matches(LEFT_DIAG[i])
    }
    for (i in RIGHT_DIAG) {
        matches += count_matches(RIGHT_DIAG[i])
    }
    print matches
}
