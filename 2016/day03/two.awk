#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    possible = 0
    corner = 0
}
$0 !~ /^ *[[:digit:]]+ +[[:digit:]]+ +[[:digit:]]+ *$/ {
    aoc::data_error()
}
{
    ++corner
    for (i = 1; i <= 3; ++i) {
        TRIANGLE[i][corner] = $i
    }
    if (corner >= 3) {
        for (i = 1; i <= 3; ++i) {
            if ((TRIANGLE[i][1] < TRIANGLE[i][2] + TRIANGLE[i][3]) &&
                (TRIANGLE[i][2] < TRIANGLE[i][1] + TRIANGLE[i][3]) &&
                (TRIANGLE[i][3] < TRIANGLE[i][1] + TRIANGLE[i][2])) {
                ++possible
                if (DEBUG) {
                    print "possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3] > DFILE
                }
            } else if (DEBUG) {
                print "NOT possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3] > DFILE
            }
        }
        corner = 0
    }
}
END {
    print possible
}
