#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }
{
    STEP = $1
    pattern = "0"
    pos = 0
    size = 1
    if (DEBUG) {
        print "(0)" > DFILE
    }
    for (count = 1; count <= 2017; ++count) {
        split(pattern, BUFFER)
        pos += STEP
        pos %= size
        ++pos
        pattern = BUFFER[1]
        for (i = 2; i <= pos; ++i) {
            pattern = pattern " " BUFFER[i]
        }
        if (DEBUG) annotated = pattern " (" count ")"
        pattern = pattern " " count
        for (; i <= size; ++i) {
            pattern = pattern " " BUFFER[i]
            if (DEBUG) annotated = annotated " " BUFFER[i]
        }
        ++size
        if (DEBUG) print annotated > DFILE
    }
    split(pattern, BUFFER)
    pos += 2
    pos %= size
    print BUFFER[pos]
}
