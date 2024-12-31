#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
    checksum = 0
    pos = 0
    block = 0
    used = 0
    free = 0
}
{
    for (i = 1; i <= NF; ++i) {
        if (i % 2) {
            for (j = 1; j <= $i; ++j) {
                USED[used++] = pos
                DISK[pos++] = block
            }
            ++block
        } else {
            for (j = 1; j <= $i; ++j) {
                FREE[free++] = pos
                DISK[pos++] = "."
            }
        }
    }
    u = used - 1
    for (f = 0; f < free && FREE[f] < used; ++f) {
        DISK[FREE[f]] = DISK[USED[u]]
        DISK[USED[u--]] = "."
    }
    for (i = 0; i < used; ++i) {
        checksum += i * DISK[i]
    }
}
END {
    print checksum
}
