#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
    REPETITIONS = 1000000000
}
$0 !~ /^((s[[:digit:]]+)|(x[[:digit:]]+\/[[:digit:]]+)|(p[a-p]\/[a-p]))(,((s[[:digit:]]+)|(x[[:digit:]]+\/[[:digit:]]+)|(p[a-p]\/[a-p])))*$/ {
    aoc::data_error()
}
{
    PROGRAMS = NF < 4 ? "abcde" : "abcdefghijklmnop"
    N = length(PROGRAMS)
    split("", op)
    split("", params)
    split("", DANCES)
    for (i = 1; i <= NF; ++i) {
        op[i] = substr($i,1,1)
        split(substr($i,2), params[i], "/")
    }
    for (dance = 0; dance < REPETITIONS; ++dance) {
        if (PROGRAMS in DANCES) {
            skip_to = dance * int(REPETITIONS / dance)
            if (DEBUG) {
                print "skipping ahead from", dance, "to", skip_to > DFILE
            }
            split("", DANCES)
            dance = skip_to
        } else {
            DANCES[PROGRAMS] = dance
        }
        for (i = 1; i <= NF; ++i) {
            p1 = params[i][1]
            p2 = params[i][2]
            switch (op[i]) {
                case "s":
                PROGRAMS = substr(PROGRAMS, N + 1 - p1) substr(PROGRAMS, 1, N - p1)
                break
                case "x":
                p1 = substr(PROGRAMS, p1 + 1, 1)
                p2 = substr(PROGRAMS, p2 + 1, 1)
                case "p":
                sub(p1, "x", PROGRAMS)
                sub(p2, p1, PROGRAMS)
                sub("x", p2, PROGRAMS)
                break
                default:
                aoc::compute_error("invalid operation " op)
            }
        }
    }
    print PROGRAMS
}
