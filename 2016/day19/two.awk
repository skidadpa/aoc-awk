#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
$0 !~ /^[[:digit:]]+$/ {
    aoc::data_error("expecting a number")
}
{
    current_num_elves = $1
    for (e = 1; e <= current_num_elves; ++e) {
        ELVES[e] = e
    }
    if (DEBUG) {
        print current_num_elves, "elves at start" > DFILE
    }
    current_taker = 1
    while (current_num_elves > 1) {
        next_num_elves = current_num_elves
        first_giver = current_taker + int(current_num_elves/2)
        if (first_giver > current_num_elves) {
            first_giver -= current_num_elves
        }
        giver = next_first_taker = first_giver
        if (DEBUG > 3) {
            print "next_first_taker index", next_first_taker, "elf", ELVES[next_first_taker] > DFILE
        }
        offset = 0
        while (current_taker != first_giver) {
            if (DEBUG > 1) {
                print ELVES[current_taker], "taking from", ELVES[giver] > DFILE
            }
            if (++current_taker > current_num_elves) {
                current_taker = 1
            }
            delete ELVES[giver]
            if (giver < (next_first_taker + offset)) {
                --next_first_taker
                ++offset
                if (DEBUG > 3) {
                    print "next_first_taker moved to index", next_first_taker, "offset", offset > DFILE
                }
            }
            if (next_num_elves % 2) {
                giver += 2
            } else {
                ++giver
            }
            if (giver > current_num_elves) {
                giver -= current_num_elves
            }
            --next_num_elves
            if (next_first_taker > next_num_elves) {
                next_first_taker -= next_num_elves
                offset = 0
                if (DEBUG > 4) {
                    print "next_first_taker adjusted to index", next_first_taker, "offset", offset > DFILE
                }
            }
        }
        current_taker = next_first_taker
        current_num_elves = asort(ELVES, ELVES, "@ind_num_asc")
        if (current_num_elves != next_num_elves) {
            aoc::compute_error("should be " next_num_elves " elves left instead of " current_num_elves)
        }
        if (DEBUG) {
            print current_num_elves, "elves left, new taker is", ELVES[current_taker] > DFILE
        }
        if (DEBUG > 2) {
            for (e = 1; e <= current_num_elves; ++e) {
                printf(" %d", ELVES[e]) > DFILE
            }
            printf("\n") > DFILE
        }
    }
    print ELVES[1]
}
