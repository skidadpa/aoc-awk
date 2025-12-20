#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function reset_map() {
    nrows = ncols = 0
    split("", rows)
    split("", cols)
}
function reflected(arr, size, i,   j) {
    for (j = 1; (i + j <= size) && (i - j >= 0); ++j) {
        if (DEBUG > 2) {
            print "COMPARING", arr[i + j], "to", arr[i + 1 - j]
        }
        if (arr[i + j] != arr[i + 1 - j]) {
            return 0
        }
    }
    return 1
}
function map_score(   score, i) {
    score = 0
    for (i = 1; i < nrows; ++i) {
        if (reflected(rows, nrows, i)) {
            if (DEBUG > 1) {
                print "MIRRORS AT ROW", i
            }
            score += i * 100
        }
    }
    for (i = 1; i < ncols; ++i) {
        if (reflected(cols, ncols, i)) {
            if (DEBUG > 1) {
                print "MIRRORS AT COLUMN", i
            }
            score += i
        }
    }
    if (DEBUG) {
        print "SCORES", score
    }
    return score
}
BEGIN {
    DEBUG = 0
    sum = 0
    reset_map()
    FS = ""
}
/^[.#]+$/ {
    if (!ncols) {
        ncols = NF
    } else if (ncols != NF) {
        aoc::data_error("current solution only support rectangular maps")
    }
    rows[++nrows] = $0
    for (i = 1; i <= NF; ++i) {
        cols[i] = cols[i] $i
    }
    if (DEBUG) {
        print
    }
    next
}
/^$/ {
    sum += map_score()
    reset_map()
    next
}
{
    aoc::data_error()
}
END {
    sum += map_score()
    print sum
}
