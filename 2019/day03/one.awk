#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="([UDLR])|([[:digit:]]+)"
}
$0 !~ /^[UDLR][[:digit:]]+(,[UDLR][[:digit:]]+)*$/ { aoc::data_error() }
(NR == 1) {
    x = y = 0
    for (i = 1; i < NF; i += 2) {
        j = i + 1
        dir = $i
        dist = $j
        switch (dir) {
        case "U":
            while (dist-- > 0) {
                WIRE[x,--y] = 1
            }
            break
        case "D":
            while (dist-- > 0) {
                WIRE[x,++y] = 1
            }
            break
        case "L":
            while (dist-- > 0) {
                WIRE[--x,y] = 1
            }
            break
        case "R":
            while (dist-- > 0) {
                WIRE[++x,y] = 1
            }
            break
        default:
            aoc::compute_error("illegal direction " dir)
        }
    }
}
function moveto(x, y) {
    if ((x SUBSEP y) in WIRE) {
        INTERSECTIONS[x,y] = aoc::abs(x) + aoc::abs(y)
    }
}
(NR == 2) {
    x = y = 0
    for (i = 1; i < NF; i += 2) {
        j = i + 1
        dir = $i
        dist = $j
        switch (dir) {
        case "U":
            while (dist-- > 0) {
                moveto(x, --y)
            }
            break
        case "D":
            while (dist-- > 0) {
                moveto(x, ++y)
            }
            break
        case "L":
            while (dist-- > 0) {
                moveto(--x, y)
            }
            break
        case "R":
            while (dist-- > 0) {
                moveto(++x, y)
            }
            break
        default:
            aoc::compute_error("illegal direction " dir)
        }
    }
}
END {
    if (NR != 2) {
        aoc::compute_error("require exactly 2 wire descriptions, got " NR)
    }
    PROCINFO["sorted_in"] = "@val_num_asc"
    for (i in INTERSECTIONS) {
        print INTERSECTIONS[i]
        exit
    }
    aoc::compute_error("there were no wire crossings")
}
