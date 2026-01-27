#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("abcdefghijklmnopqrstuvwxyz", LETTERS, "")
    pairs = ""
    sep = "("
    for (l in LETTERS) {
        pairs = pairs sep "(" toupper(LETTERS[l]) LETTERS[l] ")|(" LETTERS[l] toupper(LETTERS[l]) ")"
        sep = "|"
    }
    pairs = pairs ")"
}
{
    MOST_REACTED = "none"
    MIN_LENGTH = 999999999
    MIN_POLYMER = "none"
    for (l in LETTERS) {
        polymer = ""
        new_polymer = gensub( "[" LETTERS[l] toupper(LETTERS[l]) "]", "", "g", $0)
        while (polymer != new_polymer) {
            polymer = new_polymer
            gsub(pairs, "", new_polymer)
            if (DEBUG > 4) {
                print polymer, "becomes", new_polymer > DFILE
            }
        }
        if (DEBUG > 1) {
            print "removing", LETTERS[l], $0, "becomes", polymer > DFILE
        }
        if (MIN_LENGTH > length(polymer)) {
            MIN_LENGTH = length(polymer)
            MIN_POLYMER = polymer
            MOST_REACTED = LETTERS[l]
        }
    }
    if (DEBUG) {
        print "after removing", MOST_REACTED, "reached smallest polymer", MIN_POLYMER, "of length", MIN_LENGTH
    }
    print MIN_LENGTH
}
$0 !~ /^[[:alpha:]]+$/ { aoc::data_error() }
