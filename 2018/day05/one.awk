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
    polymer = ""
    new_polymer = $0
    while (polymer != new_polymer) {
        polymer = new_polymer
        gsub(pairs, "", new_polymer)
        if (DEBUG > 1) {
            print polymer, "becomes", new_polymer > DFILE
        }
    }
    if (DEBUG) {
        print $0, "becomes", polymer > DFILE
    }
    print length(polymer)
}
$0 !~ /^[[:alpha:]]+$/ { aoc::data_error() }
