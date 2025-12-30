#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1 || $0 !~ /^[[:digit:]]+$/) { aoc::data_error() }
{ jar_sizes[NR] = int($1) }
function ways_to_fill(jars, nog,   count, i, j, jars_to_try, nog_needed, avail) {
    count = 0
    for (i = 1; i <= length(jars); ++i) {
        if (jars[i] == nog) ++count
        if (jars[i] >= nog) continue
        nog_needed = nog - jars[i]
        delete jars_to_try
        avail = 0
        for (j = 1; j <= length(jars) - i; ++j) {
            jars_to_try[j] = jars[i + j]
            avail += jars_to_try[j]
        }
        if (avail == nog_needed) ++count
        if (avail <= nog_needed) return count
        count += ways_to_fill(jars_to_try, nog_needed)
    }
    return count
}
END {
    print ways_to_fill(jar_sizes, 150)
}
