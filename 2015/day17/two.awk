#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
}
(NF != 1 || $0 !~ /^[[:digit:]]+$/) { aoc::data_error() }
{ jar_sizes[NR] = int($1) }
function ways_to_fill(jars, nog, count,   i, j, jars_to_try, nog_needed, avail) {
    ++count
    for (i = 1; i <= length(jars); ++i) {
        if (jars[i] == nog) ++WAYS[count]
        if (jars[i] >= nog) continue
        nog_needed = nog - jars[i]
        delete jars_to_try
        avail = 0
        for (j = 1; j <= length(jars) - i; ++j) {
            jars_to_try[j] = jars[i + j]
            avail += jars_to_try[j]
        }
        if (avail == nog_needed) ++WAYS[count + length(jars_to_try)]
        if (avail <= nog_needed) return
        ways_to_fill(jars_to_try, nog_needed, count)
    }
    return count
}
END {
    ways_to_fill(jar_sizes, 150, 0)
    if (DEBUG) {
        for (w in WAYS) print w, WAYS[w] > DFILE
    }
    for (w in WAYS) {
        print WAYS[w]
        break
    }
}
