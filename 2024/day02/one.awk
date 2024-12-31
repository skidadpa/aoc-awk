#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
}
$0 !~ /^[0-9 ]*$/ { aoc::data_error() }
NF < 2 { aoc::data_error("too few fields") }
{
    left = 0 + $1
    right = 0 + $2
    increasing = (left < right)
    for (i = 1; i < NF; ++i) {
        left = 0 + $(i)
        right = 0 + $(i + 1)
        if (increasing) {
            smaller = left
            larger = right
        } else {
            smaller = right
            larger = left
        }
        diff = larger - smaller
        if ((diff < 1) || (diff > 3)) {
            if (DEBUG) {
                print "UNSAFE:", $0
            }
            next
        }
    }
    ++safe
    if (DEBUG) {
        print "SAFE:", $0
    }
}
END {
    print safe
}
