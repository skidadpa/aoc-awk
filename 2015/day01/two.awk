#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) { aoc::data_error() }
function tobasement(moves,    n, i, level) {
    n = split(moves, move, "")
    for (i = 1; i <= n; ++i) {
        level += (move[i] == "(") ? 1 : -1
        if (level < 0) return i
    }
    return "NONE"
}
{
    print tobasement($1)
}
