#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NR == 1) { ncrabs = split($1, crabs,",") }
(NR > 1 || NF > 1) { aoc::data_error() }
function fuelcost(from, to,    distance) {
    distance = from > to ? from - to : to - from
    return distance * (distance + 1) / 2
}
END {
    minpos = 99999; maxpos = 0
    for (i in crabs) {
        if (crabs[i] < minpos) minpos = crabs[i]
        if (crabs[i] > maxpos) maxpos = crabs[i]
    }
    minfuel = 9999999999
    for (pos = minpos; pos <= maxpos; ++pos) {
        fuel = 0
        for (i in crabs) fuel += fuelcost(crabs[i], pos)
        if (fuel < minfuel) { minfuel = fuel }
    }
    print minfuel
}
