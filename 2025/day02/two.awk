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
        for (n = $begin; n <= $end; ++n) {
            id = "" n
            size = length(id)
            half = size / 2
            # This is very inefficient, could optimize fail checks and/or compare to substr()
            for (len = 1; len <= half; ++len) {
                if (size % len) {
                    continue
                }
                if (match(id, "^(" substr(id, 1, len) "){" size / len "}$")) {
                    if (DEBUG > 2) {
                        print id, "is illegal" > DFILE
                    }
                    SUM += 0 + id
                    break
                }
            }
        }
    }
}
END {
    print SUM
}
