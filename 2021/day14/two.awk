#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FS = " -> " }
(NF != (NR > 2 ? 2 : 2 - NR)) { aoc::data_error() }
(NR == 1) { poly = $1; next }
(NR > 2) {
    n = split($1, map, "")
    elements[map[1]] = elements[map[2]] = elements[$2] = 0
    if (n != 2) { aoc::data_error() }
    rules[map[1],map[2]] = $2
}
END {
    n = split(poly, initial_polymer, "")
    for (i in initial_polymer) elements[initial_polymer[i]] = 0
    if (length(elements) * length(elements) + 2 != NR) { aoc::data_error() }

    for (i = 1; i < n; ++i) pairs[0][initial_polymer[i],initial_polymer[i+1]]++
    for (step = 1; step <= 40; ++step) {
        for (c in pairs[step - 1]) {
            split(c, map, SUBSEP)
            pairs[step][map[1], rules[c]] += pairs[step - 1][c]
            pairs[step][rules[c], map[2]] += pairs[step - 1][c]
        }
    }

    ++elements[initial_polymer[n]]; ++elements[initial_polymer[1]]
    for (c in pairs[40]) {
        split(c, map, SUBSEP)
        elements[map[1]] += pairs[40][c]
        elements[map[2]] += pairs[40][c]
    }
    min = max = initial_polymer[1]
    for (i in elements) {
        if (elements[i] < elements[min]) min = i
        if (elements[i] > elements[max]) max = i
    }
    print elements[max] / 2 - elements[min] / 2
}
