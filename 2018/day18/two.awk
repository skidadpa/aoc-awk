#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function coords(c) {
    return sprintf("[%d,%d]", (c % WIDTH), int(c / WIDTH))
}
function dump(t,   prev, c) {
    print "time", t > DFILE
    prev = WIDTH
    for (c in MAP) {
        if (c != prev + 1) {
            printf "\n" > DFILE
        }
        if (c in OPEN[t]) {
            printf "." > DFILE
        } else if (c in TREES[t]) { 
            printf "|" > DFILE
        } else if (c in YARDS[t]) {
            printf "#" > DFILE
        } else {
            aoc::data_error(coords(c) " in unknown state")
        }
        prev = c
    }
    printf "\n" > DFILE
}
BEGIN {
    FS = ""
    WIDTH = 100
    MOVES[-WIDTH - 1] = MOVES[-WIDTH] = MOVES[-WIDTH + 1] = 1
    MOVES[-1] = MOVES[1] = 1
    MOVES[WIDTH - 1] = MOVES[WIDTH] = MOVES[WIDTH + 1] = 1
    PROCINFO["sorted_in"] = "@ind_num_asc"
}
$0 !~ /^[.#|]+$/ { aoc::data_error() }
{
    for (i = 1; i <= NF; ++i) {
        c = NR * WIDTH + i
        MAP[c] = 1
        switch ($i) {
        case ".":
            OPEN[0][c] = 1
            break
        case "|":
            TREES[0][c] = 1
            break
        case "#":
            YARDS[0][c] = 1
            break
        default:
            aoc::compute_error("unexpected data " $i)
        }
    }
}
END {
    TOTAL_TIME = 1000000000 
    split("", VALUES)
    matched_at = 0
    stride = 0
    for (t = 0; t < TOTAL_TIME; ++t) {
        VALUES[t] = length(TREES[t]) * length(YARDS[t])
        if (VALUES[t] in LAST_SEEN) {
            if (matched_at && (t - LAST_SEEN[VALUES[t]] == stride)) {
                if (t >= matched_at + stride) {
                    break
                }
            } else {
                matched_at = t
                stride = t - LAST_SEEN[VALUES[t]]
                if (DEBUG) {
                    print "matched", VALUES[t], "at", t, "stride", stride > DFILE
                    if (++count > 100) {
                        exit
                    }
                }
            }
        } else {
            matched_at = 0
        }
        LAST_SEEN[VALUES[t]] = t
        VALUES_SEEN[resource_value][t] = 1
        if (DEBUG > 5) {
            dump(t)
        }
        for (c in OPEN[t]) {
            test = 0
            for (m in MOVES) {
                if ((c + m) in TREES[t]) {
                    ++test
                    if (test >= 3) {
                        break
                    }
                }
            }
            if (test >= 3) {
                TREES[t + 1][c] = 1
            } else {
                OPEN[t + 1][c] = 1
            }
        }
        for (c in TREES[t]) {
            test = 0
            for (m in MOVES) {
                if ((c + m) in YARDS[t]) {
                    ++test
                    if (test >= 3) {
                        break
                    }
                }
            }
            if (test >= 3) {
                YARDS[t + 1][c] = 1
            } else {
                TREES[t + 1][c] = 1
            }
        }
        for (c in YARDS[t]) {
            test1 = 0
            test2 = 0
            for (m in MOVES) {
                if ((c + m) in YARDS[t]) {
                    test1 = 1
                }
                if ((c + m) in TREES[t]) {
                    test2 = 1
                }
                if (test1 && test2) {
                    break
                }
            }
            if (test1 && test2) {
                YARDS[t + 1][c] = 1
            } else {
                OPEN[t + 1][c] = 1
            }
        }
        delete OPEN[t]
        delete TREES[t]
        delete YARDS[t]
    }
    if (DEBUG > 5) {
        dump(t)
    }
    if (matched_at) {
        print VALUES[matched_at + ((TOTAL_TIME - matched_at) % stride)]
    } else {
        print length(TREES[t]) * length(YARDS[t])
    }
}
