#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
$0 !~ /^[[:digit:]]+ players; last marble is worth [[:digit:]]+ points$/ { aoc::data_error() }
{
    num_players = $1
    num_marbles = $2
    split("", SCORE)
    curr = 0
    PREV[curr] = NEXT[curr] = curr
    if (DEBUG) {
        printf "[0]" > DFILE
        d = curr
        do {
            d = NEXT[d]
            printf " %d", d > DFILE
        } while (d != curr)
        printf "\n" > DFILE
    }
    for (m = 1; m <= num_marbles; ++m) {
        if ((m % 23) == 0) {
            take = PREV[PREV[PREV[PREV[PREV[PREV[PREV[curr]]]]]]]
            curr = NEXT[take]
            NEXT[PREV[take]] = curr
            PREV[curr] = PREV[take]
            delete PREV[take]
            delete NEXT[take]
            SCORE[m % num_players] += m + take
        } else {
            curr = NEXT[curr]
            NEXT[m] = NEXT[curr]
            PREV[m] = curr
            PREV[NEXT[curr]] = m
            NEXT[curr] = m
            curr = m
        }
        if (DEBUG) {
            printf "[%d]", m > DFILE
            d = curr
            do {
                d = NEXT[d]
                printf " %d", d > DFILE
            } while (d != curr)
            printf "\n" > DFILE
        }
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (p in SCORE) {
        print SCORE[p]
        next
    }
    print 0
}
