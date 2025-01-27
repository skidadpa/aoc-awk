#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
}
$0 !~ /^[[:digit:]]+( [[:digit:]]+)*$/ {
    aoc::data_error()
}
{
    split("", BLINK[0])
    for (i = 1; i <= NF; ++i) {
        BLINK[0][i] = 0 + $i
    }
    if (DEBUG) {
        printf("START (%d stones):", length(BLINK[0]))
        for (i in BLINK[0]) {
            printf(" %d", BLINK[0][i])
        }
        printf("\n")
    }
    for (b = 1; b <= 25; ++b) {
        if (DEBUG) {
            printf("Pass %d", b)
        }
        split("", BLINK[b])
        pos = 0
        for (i in BLINK[b-1]) {
            val = BLINK[b-1][i]
            if (val == 0) {
                BLINK[b][++pos] = 1
            } else {
                len = length("" val)
                if (len % 2 == 0) {
                    BLINK[b][++pos] = 0 + substr(val, 1, len/2)
                    BLINK[b][++pos] = 0 + substr(val, len/2 + 1)
                } else {
                    BLINK[b][++pos] = 2024 * val
                }
            }
        }
        if (DEBUG) {
            printf(" (%d stones)", length(BLINK[b]))
            if (DEBUG > 1) {
                printf(":")
                for (i in BLINK[b]) {
                    printf(" %s", BLINK[b][i])
                }
            }
            printf("\n")
        }
    }
}
END {
    print length(BLINK[25])
}
