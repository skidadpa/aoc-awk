#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
}
$0 !~ /^(n|s|(ne)|(se)|(nw)|sw)(,(n|s|(ne)|(se)|(nw)|sw))*$/ {
    aoc::data_error()
}
{
    x = y = maxdist = 0
    for (i = 1; i <= NF; ++i) {
        switch ($i) {
        case "n":
            ++y
            break
        case "ne":
            y += 0.5
            ++x
            break
        case "se":
            y -= 0.5
            ++x
            break
        case "s":
            --y
            break
        case "sw":
            y -= 0.5
            --x
            break
        case "nw":
            y += 0.5
            --x
            break
        default:
            aoc::data_error("unrecognized direction " $i)
        }
        disty = (y > 0) ? y : -y
        distx = (x > 0) ? x : -x
        disty -= (distx / 2)
        dist = (disty > 0) ? distx + disty : distx
        if (maxdist < dist) {
            maxdist = dist
        }
        if (DEBUG) {
            print "after", $i, "y =", y, "x =", x, "dist =", dist > DFILE
        }
    }
    print maxdist
}
