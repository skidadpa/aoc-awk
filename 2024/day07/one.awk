#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FS = "[: ]+"
    result = 0
}
$0 !~ /^[[:digit:]]+:( [[:digit:]]+){2,}$/ {
    aoc::data_error()
}
/ 0/ {
    aoc::data_error("unsupported zero coefficient")
}
{
    split("", VALUES)
    ++VALUES[2][$2]
    for (i = 3; i < NF; ++i) {
        split("", VALUES[i])
        for (v in VALUES[i - 1]) {
            if (v + $i <= $1) {
                ++VALUES[i][v + $i]
            }
            if (v * $i <= $1) {
                ++VALUES[i][v * $i]
            }
        }
    }
    for (v in VALUES[NF - 1]) {
        if (DEBUG) {
            print "testing", v + $NF, "against", $1
        }
        if (v + $NF == $1) {
            result += $1
            next
        }
        if (DEBUG) {
            print "testing", v * $NF, "against", $1
        }
        if (v * $NF == $1) {
            result += $1
            next
        }
    }
}
END {
    print result
}
