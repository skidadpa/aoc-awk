#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
$0 !~ /^[[:digit:]]+ <-> [[:digit:]]+(, [[:digit:]]+)*$/ {
    aoc::data_error()
}
{
    DISTANCE[$1][0][$1] = 0
    for (i = 2; i <= NF; ++i) {
        DISTANCE[$1][1][$i] = DISTANCE[$i][1][$1] = 1
        PROGRAMS_TO_CHECK[$1] = PROGRAMS_TO_CHECK[$i] = 1
    }
}
END {
    while (length(PROGRAMS_TO_CHECK) > 0) {
        for (start in PROGRAMS_TO_CHECK) {
            break
        }
        if (DEBUG) {
            print "Programs to check:" > DFILE
            for (i in PROGRAMS_TO_CHECK) {
                print i > DFILE
            }
            print "creating group including", start > DFILE
        }
        GROUP[start][start] = 0
        delete PROGRAMS_TO_CHECK[start]
        for (dist = 0; length(DISTANCE[start][dist]); ++dist) {
            for (src in DISTANCE[start][dist]) {
                for (dst in DISTANCE[src][1]) {
                    if (!(dst in GROUP[start])) {
                        delete PROGRAMS_TO_CHECK[dst]
                        GROUP[start][dst] = dist + 1
                        DISTANCE[start][dist + 1][dst] = dist + 1
                    }
                }
            }
        }
    }
    if (DEBUG) {
        print "groups:" > DFILE
        for (i in GROUP) {
            print i, "of size", length(GROUP[i]) > DFILE
        }
    }
    print length(GROUP)
}
