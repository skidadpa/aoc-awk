#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NR == 1) { ncrabs = split($1, crabs,",") }
(NR > 1 || NF > 1) { aoc::data_error() }
END {
    minpos = 99999; maxpos = 0
    for (i in crabs) {
        if (crabs[i] < minpos) minpos = crabs[i]
        if (crabs[i] > maxpos) maxpos = crabs[i]
    }
    minfuel = 9999999999
    for (pos = minpos; pos <= maxpos; ++pos) {
        f = 0
        for (i in crabs) f += crabs[i] > pos ? crabs[i] - pos : pos - crabs[i]
        if (f < minfuel) { minfuel = f }
    }
    print minfuel
}
