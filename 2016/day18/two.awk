#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
$0 !~ /^[.^]+$/ {
    aoc::data_error()
}
{
    delete TRAPS
    COLUMNS = split($0, ROW, "")
    ROWS = 400000
    for (c in ROW) {
        if (ROW[c] == "^") {
            TRAPS[1][c] = 1
        }
    }
    safe_squares = COLUMNS - length(TRAPS[1])
    for (r = 1; r < ROWS; ++r) {
        for (c = 1; c <= COLUMNS; ++c) {
            if (c-1 in TRAPS[r]) {
                if (!(c+1 in TRAPS[r])) {
                    TRAPS[r+1][c] = 1
                }
            } else if (c+1 in TRAPS[r]) {
                TRAPS[r+1][c] = 1
            }
        }
        delete TRAPS[r]
        safe_squares += COLUMNS - length(TRAPS[r+1])
    }
    print safe_squares
}
