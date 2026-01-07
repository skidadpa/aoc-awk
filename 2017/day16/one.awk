#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
}
$0 !~ /^((s[[:digit:]]+)|(x[[:digit:]]+\/[[:digit:]]+)|(p[a-p]\/[a-p]))(,((s[[:digit:]]+)|(x[[:digit:]]+\/[[:digit:]]+)|(p[a-p]\/[a-p])))*$/ {
    aoc::data_error()
}
{
    PROGRAMS = NF < 4 ? "abcde" : "abcdefghijklmnop"
    N = length(PROGRAMS)
    for (i = 1; i <= NF; ++i) {
        op = substr($i,1,1)
        split(substr($i,2), params, "/")
        if (DEBUG) {
            printf "%s, %s %s", PROGRAMS, op, substr($i,2) > DFILE
        }
        switch (op) {
        case "s":
            PROGRAMS = substr(PROGRAMS, N + 1 - params[1]) substr(PROGRAMS, 1, N - params[1])
            break
        case "x":
            params[1] = substr(PROGRAMS, params[1] + 1, 1)
            params[2] = substr(PROGRAMS, params[2] + 1, 1)
        case "p":
            sub(params[1], "x", PROGRAMS)
            sub(params[2], params[1], PROGRAMS)
            sub("x", params[2], PROGRAMS)
            break
        default:
            aoc::compute_error("invalid operation " op)
        }
        if (DEBUG) {
            print " ->", PROGRAMS > DFILE
        }
    }
    print PROGRAMS
}
