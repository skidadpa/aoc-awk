#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
}
$0 !~ /^[0-9 ]*$/ { aoc::data_error() }
NF < 4 { aoc::data_error("too few fields") }
{
    if (DEBUG > 1) {
        print "TESTING :", $0
    }
    for (pass = 0; pass < NF; ++pass) {
        dampened = pass ? pass : NF
        left = 0 + $(dampened <= 1 ? 2 : 1)
        right = 0 + $(dampened <= 2 ? 3 : 2)
        increasing = (left < right)
        if (DEBUG > 1) {
            print "skipping", dampened, ":", increasing ? "increasing" : "decreasing"
        }
        for (i = 1; i < NF - 1; ++i) {
            left = 0 + $(dampened <= i ? i + 1 : i)
            right = 0 + $(dampened <= i + 1 ? i + 2 : i + 1)
            if (increasing) {
                smaller = left
                larger = right
            } else {
                smaller = right
                larger = left
            }
            diff = larger - smaller
            if ((diff < 1) || (diff > 3)) {
                if (DEBUG > 1) {
                    print "fails from", left, "to", right
                }
                break
            }
        }
        if (i >= NF - 1) {
            break
        }
    }
    if (pass < NF) {
        ++safe
    }
    if (DEBUG) {
        if (pass < NF) {
           print "SAFE (", dampened, "):", $0
       } else {
           print "UNSAFE:", $0
       }
    }
}
END {
    print safe
}
