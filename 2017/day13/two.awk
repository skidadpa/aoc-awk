#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
    DELAY_LIMIT = 5000000
}
$0 !~ /^[[:digit:]]+: [[:digit:]]+$/ {
    aoc::data_error()
}
{
    DEPTH[$1] = $2
    DIRECTION[$1] = 1
    if (max_range < $1) {
        max_range = $1
    }
}
END {
    for (i in DEPTH) {
        MOD[i] = DEPTH[i] * 2 - 2
        POS[i] = i
        while (POS[i] >= MOD[i]) {
            POS[i] -= MOD[i]
        }
    }
    path_found = 0
    for (delay = 0; delay < DELAY_LIMIT; ++delay) {
        path_found = delay
        for (i in POS) {
            if (POS[i] == 0) {
                if (DEBUG && path_found) {
                    print "scanner", i, "catches packet at delay", delay > DFILE
                }
                path_found = 0
            }
            ++POS[i]
            if (POS[i] >= MOD[i]) {
                POS[i] -= MOD[i]
            }
        }
        if (path_found) {
            found_at = delay
            break
        }
    }
    if (delay >= DELAY_LIMIT) {
        aoc::compute_error("no solution found after delay " delay)
    }
    print found_at
}
