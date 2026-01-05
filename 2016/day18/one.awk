#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
$0 !~ /^[.^]+$/ {
    aoc::data_error()
}
{
    delete TRAPS
    COLUMNS = split($0, ROW, "")
    if (COLUMNS > 10) {
        ROWS = 40
    } else if (COLUMNS < 10) {
        ROWS = 3
    } else {
        ROWS = 10
    }
    for (c in ROW) {
        if (ROW[c] == "^") {
            TRAPS[1,c] = 1
        }
    }
    for (r = 1; r < ROWS; ++r) {
        for (c = 1; c <= COLUMNS; ++c) {
            if ((r,c-1) in TRAPS) {
                if (!((r,c+1) in TRAPS)) {
                    TRAPS[r+1,c] = 1
                }
            } else if ((r,c+1) in TRAPS) {
                TRAPS[r+1,c] = 1
            }
        }
    }
    print ROWS * COLUMNS - length(TRAPS)
}
