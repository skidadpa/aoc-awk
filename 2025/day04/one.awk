#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
}
$0 !~ /^[.@]+$/ {
    aoc::data_error()
}
{
    for (i = 1; i <= NF; ++i) {
        if ($i == "@") {
            ROLLS[i,NR] = 1
        }
    }
}
END {
    sum = 0
    for (coords in ROLLS) {
        split(coords, c, SUBSEP)
        x = c[1]
        y = c[2]
        adjacent = (((x - 1) SUBSEP (y - 1)) in ROLLS) + \
                   (((  x  ) SUBSEP (y - 1)) in ROLLS) + \
                   (((x + 1) SUBSEP (y - 1)) in ROLLS) + \
                   (((x - 1) SUBSEP (  y  )) in ROLLS) + \
                   (((x + 1) SUBSEP (  y  )) in ROLLS) + \
                   (((x - 1) SUBSEP (y + 1)) in ROLLS) + \
                   (((  x  ) SUBSEP (y + 1)) in ROLLS) + \
                   (((x + 1) SUBSEP (y + 1)) in ROLLS)
        if (adjacent < 4) {
            ++sum
        }
        if (DEBUG) {
            print "[" x "," y "] :", adjacent, "adjacent,", ((adjacent < 4) ? "ACCESSIBLE" : "inaccessible") > DFILE
        }
    }
    print sum
}
