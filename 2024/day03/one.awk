#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FPAT = "mul\\([[:digit:]]{1,3},[[:digit:]]{1,3}\\)"
}
{
    if (DEBUG) {
        print NF, "ops in", $0
    }
    for (i = 1; i <= NF; ++i) {
        if (DEBUG) {
            print "operation", $i
        }
        split($i, op, /[(,)]/)
        total += op[2] * op[3]
    }
}
END {
    print total
}
