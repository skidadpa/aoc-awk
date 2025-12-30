#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    xadd[">"] = 1
    xadd["<"] = -1
    yadd["^"] = 1
    yadd["v"] = -1
}
(NF != 1) { aoc::data_error() }
{
    x = y = 0
    n = split($1, moves, "")
    split("", houses)
    ++houses[x,y]
    for (i in moves) {
        x += xadd[moves[i]]
        y += yadd[moves[i]]
        ++houses[x,y]
    }
    print length(houses)
}
