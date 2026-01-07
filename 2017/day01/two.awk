#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
}
($0 !~ /^[[:digit:]]+$/) || ((NF % 2) != 0) {
    aoc::data_error()
}
{
    sum = 0
    for (i = 1; i <= NF; ++i) {
        j = (i <= (NF / 2)) ? (i + (NF / 2)) : (i - (NF / 2))
        if ($i == $j) {
            if (DEBUG > 1) {
                print i, $i, "==", $j, j > DFILE
            }
            sum += $i
        } else {
            if (DEBUG > 1) {
                print i, $i, "!=", $j, j > DFILE
            }
        }
    }
    if (DEBUG) {
        printf("%s => ", $0) > DFILE
    }
    print sum
}
