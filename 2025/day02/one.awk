#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "[-,]"
    SUM = 0
}
$0 !~ /^[[:digit:]]+-[[:digit:]]+(,[[:digit:]]+-[[:digit:]]+)*$/ {
    aoc::data_error()
}
NR != 1 {
    aoc::data_error("More than one line in input")
}
{
    if (DEBUG) {
        print NF / 2, "ranges to check" > DFILE
    }
    for (begin = 1; begin < NF; begin += 2) {
        end = begin + 1
        if (DEBUG > 1) {
            print " ", $begin, "-", $end > DFILE
        }
        for (i = $begin; i <= $end; ++i) {
            id = "" i
            size = length(id)
            if (size % 2) {
                gsub(/./, "9", id)
                if (DEBUG > 3) {
                    print "skipping from", i, "to", id > DFILE
                }
                i = 0 + id
                continue
            }
            half = size / 2
            if (substr(id, 1, half) == substr(id, half+1, half)) {
                if (DEBUG > 2) {
                    print id, "is illegal" > DFILE
                }
                SUM += 0 + id
            }
        }
    }
}
END {
    print SUM
}
