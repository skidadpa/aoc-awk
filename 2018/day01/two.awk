#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    LIMIT = 10000000
}
{ DELTA[NR] = int($1) }
END {
    count = 0
    frequency = 0
    split("", FREQUENCIES)
    FREQUENCIES[frequency] = count++
    while (1) {
        for (i = 1; i <= NR; ++i) {
            if (DEBUG) {
                print count, ":", frequency, "+", DELTA[i], "=", frequency + DELTA[i] > DFILE
            }
            frequency += DELTA[i]
            if (frequency in FREQUENCIES) {
                print frequency
                exit
            }
            FREQUENCIES[frequency] = count++
        }
        if (count >= LIMIT) {
            aoc::compute_error("did not find a match in " LIMIT " deltas")
        }
    }
}
