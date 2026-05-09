#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="([UDLR])|([[:digit:]]+)"
}
$0 !~ /^[UDLR][[:digit:]]+(,[UDLR][[:digit:]]+)*$/ { aoc::data_error() }
function moveto(wire, x, y) {
    ++STEPS
    if (wire == 1) {
        if (!((x SUBSEP y) in WIRE)) {
            WIRE[x,y] = STEPS
        }
    } else if (wire == 2) {
        if (((x SUBSEP y) in WIRE) && !((x SUBSEP y) in INTERSECTIONS)) {
            INTERSECTIONS[x,y] = WIRE[x,y] + STEPS
        }
    } else {
        aoc::compute_error("tried to move wire " wire " should be in range 1-2")
    }
}
{
    x = y = 0
    STEPS = 0
    for (i = 1; i < NF; i += 2) {
        j = i + 1
        dir = $i
        dist = $j
        switch (dir) {
        case "U":
            while (dist-- > 0) {
                moveto(NR, x, --y)
            }
            break
        case "D":
            while (dist-- > 0) {
                moveto(NR, x, ++y)
            }
            break
        case "L":
            while (dist-- > 0) {
                moveto(NR, --x, y)
            }
            break
        case "R":
            while (dist-- > 0) {
                moveto(NR, ++x, y)
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
