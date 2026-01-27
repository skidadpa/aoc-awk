#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function consume_node(start,   i, h1, h2, j) {
    if (i > length(DATA)) {
        aoc::compute_error(i " is larger than data count " length(DATA))
    }
    i = start
    h1 = i++
    h2 = i++
    if (DEBUG) {
        print "consuming from", start, "with", DATA[h1], "subnodes and", DATA[h2], "metadata" > DFILE
    }
    for (j = 1; j <= DATA[h1]; ++j) {
        i = consume_node(i)
    }
    for (j = 1; j <= DATA[h2]; ++j) {
        METADATA_TOTAL += DATA[i]
        ++i
    }
    return i
}
{
    for (i = 1; i <= NF; ++i) {
        DATA[i] = $i
    }
    consume_node(1)
}
END {
    print METADATA_TOTAL
}
