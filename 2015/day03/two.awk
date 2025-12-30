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
    santax = santay = robosantax = robosantay = 0
    n = split($1, moves, "")
    split("", houses)
    ++houses[santax,santay]
    ++houses[robosantax,robosantay]
    for (i in moves) {
        if (i % 2) {
            santax += xadd[moves[i]]
            santay += yadd[moves[i]]
            ++houses[santax,santay]
        } else {
            robosantax += xadd[moves[i]]
            robosantay += yadd[moves[i]]
            ++houses[robosantax,robosantay]
        }
    }
    print length(houses)
}
