#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NR == 1) && ($0 ~ /^#ip [[:digit:]]$/) {
    next
}
$0 !~ /^((addr)|(addi)|(mulr)|(muli)|(banr)|(bani)|(borr)|(bori)|(setr)|(seti)|(gtir)|(gtri)|(gtrr)|(eqir)|(eqri)|(eqrr)) [[:digit:]]+ [[:digit:]]+ [[:digit:]]$/ {
    aoc::data_error()
}
END {
    # this is a transformation of the program, probably should at least get immediate values from the input
    r3 = r5 = 0
    do {
        r5 = or(r3, 65536)
        r3 = 5557974
        while (r5 > 0) {
            r3 = and(and(r3 + and(r5, 255),16777215) * 65899, 16777215)
            r5 = int(r5 / 256)
        }
        if (r3 in SEEN) {
            print last_seen
            exit
        }
        SEEN[r3] = ++count
        last_seen = r3
    } while (1)
}
