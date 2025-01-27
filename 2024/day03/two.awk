#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FPAT = "(mul\\([[:digit:]]{1,3},[[:digit:]]{1,3}\\))|(do\\(\\))|(don't\\(\\))"
    enabled = 1
}
{
    if (DEBUG) {
        print NF, "ops in", $0
    }
    for (i = 1; i <= NF; ++i) {
        if (DEBUG) {
            print "operation", $i
        }
        switch (substr($i, 3, 1)) {
        case "(":
            if (DEBUG > 1) {
                print "enabling"
            }
            enabled = 1
            break
        case "n":
            if (DEBUG > 1) {
                print "disabling"
            }
            enabled = 0
            break
        case "l":
            if (enabled) {
                if (DEBUG > 1) {
                    print "multiplying"
                }
                split($i, op, /[(,)]/)
                total += op[2] * op[3]
            }
            break
        default:
            aoc::error("PROGRAM ERROR parsing " $0)
        }
    }
}
END {
    print total
}
