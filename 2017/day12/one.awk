#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
$0 !~ /^[[:digit:]]+ <-> [[:digit:]]+(, [[:digit:]]+)*$/ {
    aoc::data_error()
}
{
    DISTANCE[$1][0][$1] = 0
    for (i = 2; i <= NF; ++i) {
        DISTANCE[$1][1][$i] = DISTANCE[$i][1][$1] = 1
    }
}
END {
    start = 0
    GROUP[start][start] = 0
    for (dist = 0; length(DISTANCE[start][dist]); ++dist) {
        for (src in DISTANCE[start][dist]) {
            for (dst in DISTANCE[src][1]) {
                if (!(dst in GROUP[start])) {
                    GROUP[start][dst] = dist + 1
                    DISTANCE[start][dist + 1][dst] = dist + 1
                }
            }
        }
    }
    print length(GROUP[start])
}
