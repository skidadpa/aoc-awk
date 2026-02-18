#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
    ROCKY = 0
    WET = 1
    NARROW = 2
    SYMBOLS[ROCKY] = "."
    SYMBOLS[WET] = "="
    SYMBOLS[NARROW] = "|"
}
/^depth: [[:digit:]]+$/ {
    if (NR != 1) { aoc::data_error("expected depth on line 1") }
    DEPTH = $1
    next
}
/^target: [[:digit:]]+,[[:digit:]]+$/ {
    if (NR != 2) { aoc::data_error("expected target on line 2") }
    TARGET_X = $1
    TARGET_Y = $2
    next
}
{ aoc::data_error() }
END {
    if (NR != 2) { aoc::data_error("expected exactly two input lines") }
    for (x = 0; x <= TARGET_X; ++x) {
        # GEOLOGIC_INDEX[x,0] = (x * 16807) % 20183
        GEOLOGIC_INDEX[x,0] = x * 16807
        EROSION_LEVEL[x,0] = (GEOLOGIC_INDEX[x,0] + DEPTH) % 20183
    }
    for (y = 0; y <= TARGET_Y; ++y) {
        # GEOLOGIC_INDEX[0,y] = (y * 48271) % 20183
        GEOLOGIC_INDEX[0,y] = y * 48271
        EROSION_LEVEL[0,y] = (GEOLOGIC_INDEX[0,y] + DEPTH) % 20183
    }
    for (x = 1; x <= TARGET_X; ++x) for (y = 1; y <= TARGET_Y; ++y) {
        GEOLOGIC_INDEX[x,y] = EROSION_LEVEL[x-1,y] * EROSION_LEVEL[x,y-1]
        EROSION_LEVEL[x,y] = (GEOLOGIC_INDEX[x,y] + DEPTH) % 20183
    }
    GEOLOGIC_INDEX[TARGET_X,TARGET_Y] = 0
    EROSION_LEVEL[TARGET_X,TARGET_Y] = DEPTH % 20183
    for (x = 0; x <= TARGET_X; ++x) for (y = 0; y <= TARGET_Y; ++y) {
        TERRAIN[x,y] = EROSION_LEVEL[x,y] % 3
    }
    if (DEBUG) {
        print "M" > DFILE
        for (y = 0; y <= TARGET_Y; ++y) {
            for (x = 0; x <= TARGET_X; ++x) {
                printf "%s", SYMBOLS[TERRAIN[x,y]] > DFILE
            }
            printf "\n" > DFILE
        }
        for (x = 0; x < TARGET_X; ++x) {
            printf " " > DFILE
        }
        printf "T\n" > DFILE
    }
    sum = 0
    for (coords in TERRAIN) {
        sum += TERRAIN[coords]
    }
    print sum
}
