#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ", "
    XMIN = 99999999
    YMIN = 99999999
    XMAX = -99999999
    YMAX = -99999999
    if (DEBUG) {
        split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", ID, "")
        ID[""] = "."
        ID[0] = "#"
    }
}
$0 !~ /^[[:digit:]]+, [[:digit:]]+$/ { aoc::data_error() }
{
    X[NR] = $1
    Y[NR] = $2
    if (XMIN > $1) {
        XMIN = $1
    }
    if (XMAX < $1) {
        XMAX = $1
    }
    if (YMIN > $2) {
        YMIN = $2
    }
    if (YMAX < $2) {
        YMAX = $2
    }
    if (DEBUG) {
        MAP[$1,$2] = NR
    }
}
END {
    area = 0
    MAX_TOTAL = (NR < 20) ? 32 : 10000
    for (x = XMIN; x <= XMAX; ++x) for (y = YMIN; y <= YMAX; ++y) {
        total = 0
        for (i = 1; i <= NR; ++i) {
            total += aoc::manhattan(x,X[i],y,Y[i])
        }
        if (total < MAX_TOTAL) {
            ++area
            if (DEBUG) {
                MAP[x,y] = 0
            }
        }
    }
    if (DEBUG) {
        for (y = YMIN; y <= YMAX; ++y) {
            for (x = XMIN; x <= XMAX; ++x) {
                printf "%s", ID[MAP[x,y]] > DFILE
            }
            printf "\n" > DFILE
        }
    }
    print area
}
