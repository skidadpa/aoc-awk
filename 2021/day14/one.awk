#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FS = " -> " }
(NF != (NR > 2 ? 2 : 2 - NR)) { aoc::data_error() }
(NR == 1) { poly = $1; next }
(NR > 2) {
    n = split($1, map, "")
    if (n != 2) { aoc::data_error() }
    rules[map[1],map[2]] = $2
}
END {
    for (step = 1; step <= 10; ++step) {
        n = split(poly, elements, "")
        nxt = elements[1]
        for (i = 1; i < n; ++i) {
            nxt = nxt rules[elements[i], elements[i+1]] elements[i+1]
        }
        poly = nxt
    }
    split(poly, elements, ""); for (i in elements) ++counts[elements[i]]; min = max = elements[1]
    for (i in counts) {
        if (counts[i] > counts[max]) max = i
        if (counts[i] < counts[min]) min = i
    }
    print counts[max] - counts[min]
}
