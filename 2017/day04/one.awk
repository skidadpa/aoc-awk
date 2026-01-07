#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    valid_passphrases = 0
}
{
    split("", WORDS)
    valid = 1
    for (i = 1; i <= NF; ++i) {
        if ($i in WORDS) {
            valid = 0
            break
        } else {
            WORDS[$i] = 1
        }
    }
    valid_passphrases += valid
}
END {
    print valid_passphrases
}
