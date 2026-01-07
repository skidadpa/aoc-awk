#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
}
$0 !~ /^(n|s|(ne)|(se)|(nw)|sw)(,(n|s|(ne)|(se)|(nw)|sw))*$/ {
    aoc::data_error()
}
{
    x = y = 0
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
            aoc::compute_error("unrecognized direction " $i)
        }
        if (DEBUG) {
            print "after", $i, "y =", y, "x =", x > DFILE
        }
    }
    y = (y > 0) ? y : -y
    x = (x > 0) ? x : -x
    if (DEBUG) {
        print "after normalization", "y =", y, "x =", x > DFILE
    }
    y -= (x / 2)
    print (y > 0) ? x + y : x
}
