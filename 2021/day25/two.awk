#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(!xmax) { xmax = length($0) }
(NF != 1 || xmax != length($1) || $0 !~ /^[.v>]+$/) { aoc::data_error() }
{
    n = split($1, row, ""); if (n != xmax) { aoc::data_error() }
    for (x = 1; x <= xmax; ++x) {
        # floor(x,NR) = row[x]
        switch (row[x]) {
            case ">": east[1][x,NR] = 1; break
            case "v": south[1][x,NR] = 1; break
        }
    }
}
function right(coord,    c) {
    split(coord, c, SUBSEP)
    return (c[1] == xmax ? 1 : c[1] + 1) SUBSEP c[2]
}
function down(coord,    c) {
    split(coord, c, SUBSEP)
    return c[1] SUBSEP (c[2] == ymax ? 1 : c[2] + 1)
}
END {
    ymax = NR
    print "MERRY CHRISTMAS AND HAPPY NEW YEAR"
}
