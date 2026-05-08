#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    FS = ","
}
$0 !~ /^-?[[:digit:]]+(,-?[[:digit:]]+){3}$/ { aoc::data_error() }
{
    POINT[NR] = $1 SUBSEP $2 SUBSEP $3 SUBSEP $4
    CONSTELLATION[NR] = NR
    split("", OVERLAPS)
    for (i = 1; i < NR; ++i) {
        if (aoc::manhattan(POINT[i], POINT[NR]) <= 3) {
            OVERLAPS[CONSTELLATION[i]] = 1
        }
    }
    for (i = 1; i < NR; ++i) {
        if (CONSTELLATION[i] in OVERLAPS) {
            CONSTELLATION[i] = NR
        }
    }
}
END {
    for (i = 1; i < NR; ++i) {
        CONSTELLATIONS[CONSTELLATION[i]][i] = i
    }
    print length(CONSTELLATIONS)
}
