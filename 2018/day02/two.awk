#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("", MATCHES)
}
{
    for (i = 1; i <= length($1); ++i) {
        matchval = substr($1, 1, i - 1) substr($1, i + 1)
        if ((i SUBSEP matchval) in MATCHES) {
            print matchval
        } else {
            MATCHES[i,matchval] = NR
        }
    }
}
