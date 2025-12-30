#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    matchrules = "children: 3\ncats: 7\nsamoyeds: 2\npomeranians: 3\n\
akitas: 0\nvizslas: 0\ngoldfish: 5\ntrees: 3\ncars: 2\nperfumes: 1"
    split(matchrules, rulelines, "\n")
    for (r in rulelines) {
        split(rulelines[r], ruleline, ": ")
        matches[ruleline[1]] = ruleline[2]
    }
    FS = "((: )|(, ))"
}
(NF != 7) { aoc::data_error() }
(DEBUG) { print $2, $3, $4, $5, $6, $7, "->", $1 }
{ if (matches[$2] == $3 && matches[$4] == $5 && matches[$6] == $7) print $1 }
