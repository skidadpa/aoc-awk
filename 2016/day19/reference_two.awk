#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 0
}
$0 !~ /^[[:digit:]]+$/ {
    print "DATA ERROR: expecting a number, saw", $0
    exit _exit=1
}
{
    num_elves = $1
    for (e = 1; e <= num_elves; ++e) {
        ELVES[e] = e
    }
    taker = 1
    if (DEBUG) {
        print num_elves, "elves at start"
    }
    if (DEBUG > 2) {
        for (e = 1; e <= num_elves; ++e) printf(" %d", ELVES[e])
        printf("\n")
    }
    while (num_elves > 1) {
        giver = taker + int(num_elves/2)
        if (DEBUG > 1) printf("%d taking from ", ELVES[taker])
        if (giver > num_elves) {
            giver -= num_elves
        } else {
            ++taker
        }
        if (DEBUG > 1) print ELVES[giver]
        delete ELVES[giver]
        num_elves = asort(ELVES, ELVES, "@ind_num_asc")
        if (taker > num_elves) {
            taker = 1
        }
        if (DEBUG) {
            print num_elves, "elves left"
        }
        if (DEBUG > 2) {
            for (e = 1; e <= num_elves; ++e) printf(" %d", ELVES[e])
            printf("\n")
        }
    }
    print ELVES[1]
}
END {
    if (_exit) {
        exit _exit
    }
}
