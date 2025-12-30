#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) { aoc::data_error() }
function look_and_say(input,    seq, n, nxt, i, j) {
    n = split(input, seq, "")
    nxt = ""
    i = 1
    while (i <= n) {
        for (j = i + 1; seq[i] == seq[j]; ++j) { }
        nxt = nxt (j - i) seq[i]
        if (DEBUG) {
            for (D = 1; D < i; ++D) printf " " > DFILE
            while (D++ < j) printf "^" > DFILE
            print "<-" (j - i) seq[i] > DFILE
        }
        i = j
    }
    if (DEBUG) {
        print nxt > DFILE
    }
    return nxt
}
{
    if (DEBUG) {
        print > DFILE
    }
    for (step = 1; step <= 40; ++step) $0 = look_and_say($0)
    print length($0)
}
