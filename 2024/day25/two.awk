#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
END {
    if (NR < 100) {
        print "MERRY"
    } else {
        print "CHRISTMAS"
    }
}
