#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function consume_node(start,   i, h1, h2, j, CHILD) {
    if (i > length(DATA)) {
        aoc::compute_error(i " is larger than data count " length(DATA))
    }
    i = start
    h1 = i++
    h2 = i++
    if (DEBUG) {
        print "consuming from", start, "with", DATA[h1], "subnodes and", DATA[h2], "metadata" > DFILE
    }
    split("", CHILD)
    for (j = 1; j <= DATA[h1]; ++j) {
        CHILD[j] = i
        i = consume_node(i)
    }
    VALUE[start] = 0
    for (j = 1; j <= DATA[h2]; ++j) {
        if (length(CHILD) > 0) {
            VALUE[start] += VALUE[CHILD[DATA[i]]]
            if (DEBUG > 1) {
                print "Child value", VALUE[CHILD[DATA[i]]], "+ VALUE[" start "] =", VALUE[start] > DFILE
            }
        } else {
            VALUE[start] += DATA[i]
            if (DEBUG > 1) {
                print "Metadata", DATA[i], "+ VALUE[" start "] =", VALUE[start] > DFILE
            }
        }
        ++i
    }
    if (DEBUG) {
        print "value of", start, "is", VALUE[start]
    }
    return i
}
{
    for (i = 1; i <= NF; ++i) {
        DATA[i] = $i
    }
    split("", VALUE)
    VALUE[""] = 0
    consume_node(1)
    print VALUE[1]
}
