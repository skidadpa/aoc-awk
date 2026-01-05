#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    possible = 0
}
$0 !~ /^ *[[:digit:]]+ +[[:digit:]]+ +[[:digit:]]+ *$/ {
    aoc::data_error()
}
{
    if (($1 < $2 + $3) && ($2 < $1 + $3) && ($3 < $1 + $2)) {
        ++possible
        if (DEBUG) {
            print "possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3] > DFILE
        }
    } else if (DEBUG) {
        print "NOT possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3] > DFILE
    }
}
END {
    print possible
}
