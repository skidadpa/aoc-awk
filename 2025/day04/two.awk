#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    DFILE = "/dev/stderr"
    FS = ""
}
$0 !~ /^[.@]+$/ {
    aoc::data_error()
}
{
    for (i = 1; i <= NF; ++i) {
        if ($i == "@") {
            ROLLS[i,NR] = 1
            ++NUM_ROLLS
        }
    }
}
END {
    do {
        split("", removable)
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
                removable[coords] = 1
            }
        }
        for (coords in removable) {
            delete ROLLS[coords]
        }
    } while (length(removable) > 0)
    print NUM_ROLLS - length(ROLLS)
}
