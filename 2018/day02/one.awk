#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
    DOUBLES = TRIPLES = 0
}
{
    split("", LETTERS)
    for (i = 1; i <= NF; ++i) {
        ++LETTERS[$i]
    }
    for (i in LETTERS) {
        if (LETTERS[i] == 2) {
            ++DOUBLES
            break
        }
    }
    for (i in LETTERS) {
        if (LETTERS[i] == 3) {
            ++TRIPLES
            break
        }
    }
}

END {
    print DOUBLES * TRIPLES
}
