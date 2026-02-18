#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function dump(pos,   c, y, x) {
    split(pos, c, SUBSEP)
    for (y = 0; y <= HEIGHT; ++y) {
        for (x = 0; x <= WIDTH; ++x) {
            if ((x == c[1]) && (y == c[2])) {
                printf "%s" , SYMBOLS[c[3]] > DFILE
            } else if ((x == TARGET_X) && (y == TARGET_Y)) {
                printf "T" > DFILE
            } else if ((x == 0) && (y == 0)) {
                printf "M" > DFILE
            } else {
                printf "%s", SYMBOLS[TERRAIN[x,y]] > DFILE
            }
        }
        printf "\n" > DFILE
    }
}
BEGIN {
    FPAT = "[[:digit:]]+"
    SOLID_ROCK = -1
    ROCKY = 0
    WET = 1
    NARROW = 2
    NEITHER = 3
    TORCH = 4
    GEAR = 5
    SYMBOLS[ROCKY] = "."
    SYMBOLS[WET] = "="
    SYMBOLS[NARROW] = "|"
    SYMBOLS[NEITHER] = "n"
    SYMBOLS[TORCH] = "t"
    SYMBOLS[GEAR] = "g"
    SWITCHABLE[NEITHER][TORCH] = SWITCHABLE[NEITHER][GEAR] = 1
    SWITCHABLE[TORCH][NEITHER] = SWITCHABLE[TORCH][GEAR] = 1
    SWITCHABLE[GEAR][NEITHER] = SWITCHABLE[GEAR][TORCH] = 1
    ACCESSIBLE[NEITHER][WET] = ACCESSIBLE[NEITHER][NARROW] = 1
    ACCESSIBLE[TORCH][ROCKY] = ACCESSIBLE[TORCH][NARROW] = 1
    ACCESSIBLE[GEAR][ROCKY] = ACCESSIBLE[GEAR][WET] = 1
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
    WIDTH = TARGET_X * 8
    HEIGHT = TARGET_Y * 4
    for (x = 0; x <= WIDTH; ++x) {
        # GEOLOGIC_INDEX[x,0] = (x * 16807) % 20183
        GEOLOGIC_INDEX[x,0] = x * 16807
        EROSION_LEVEL[x,0] = (GEOLOGIC_INDEX[x,0] + DEPTH) % 20183
    }
    for (y = 0; y <= HEIGHT; ++y) {
        # GEOLOGIC_INDEX[0,y] = (y * 48271) % 20183
        GEOLOGIC_INDEX[0,y] = y * 48271
        EROSION_LEVEL[0,y] = (GEOLOGIC_INDEX[0,y] + DEPTH) % 20183
    }
    for (x = 1; x <= WIDTH; ++x) for (y = 1; y <= HEIGHT; ++y) {
        GEOLOGIC_INDEX[x,y] = EROSION_LEVEL[x-1,y] * EROSION_LEVEL[x,y-1]
        EROSION_LEVEL[x,y] = (GEOLOGIC_INDEX[x,y] + DEPTH) % 20183
    }
    GEOLOGIC_INDEX[TARGET_X,TARGET_Y] = 0
    EROSION_LEVEL[TARGET_X,TARGET_Y] = DEPTH % 20183
    for (x = 0; x <= WIDTH; ++x) {
        TERRAIN[x,-1] = TERRAIN[x,HEIGHT+1] = SOLID_ROCK
    }
    for (y = 0; y <= HEIGHT; ++y) {
        TERRAIN[-1,y] = TERRAIN[WIDTH+1,y] = SOLID_ROCK
    }
    for (x = 0; x <= WIDTH; ++x) for (y = 0; y <= HEIGHT; ++y) {
        TERRAIN[x,y] = EROSION_LEVEL[x,y] % 3
    }
    START = 0 SUBSEP 0 SUBSEP TORCH
    TARGET = TARGET_X SUBSEP TARGET_Y SUBSEP TORCH
    if (DEBUG > 2) {
        dump(START)
    }
    DISTANCES[0][START] = ""
    DISTANCE_LIMIT = 10000
    split("", SEEN)
    for (d = 0; d <= DISTANCE_LIMIT; ++d) {
        if (DEBUG > 1) {
            if (d % 100 == 0) {
                print "distance", d > DFILE
            }
        }
        for (pos in DISTANCES[d]) {
            if (pos in SEEN) {
                continue
            }
            SEEN[pos] = 1
            path = DISTANCES[d][pos]
            if (pos == TARGET) {
                if (DEBUG) {
                    print path > DFILE
                }
                print d
                exit
            }
            split(pos, c, SUBSEP)
            if (DEBUG > 10) {
                printf "%d:[%d,%d](%s)\n", d, c[1], c[2], SYMBOLS[c[3]] > DFILE
            }
            for (e in SWITCHABLE[c[3]]) if (TERRAIN[c[1],c[2]] in ACCESSIBLE[e]) {
                DISTANCES[d+7][c[1],c[2],e] = path SYMBOLS[e]
            }
            if (TERRAIN[c[1]-1,c[2]] in ACCESSIBLE[c[3]]) {
                DISTANCES[d+1][c[1]-1,c[2],c[3]] = path "l"
            }
            if (TERRAIN[c[1]+1,c[2]] in ACCESSIBLE[c[3]]) {
                DISTANCES[d+1][c[1]+1,c[2],c[3]] = path "r"
            }
            if (TERRAIN[c[1],c[2]-1] in ACCESSIBLE[c[3]]) {
                DISTANCES[d+1][c[1],c[2]-1,c[3]] = path "u"
            }
            if (TERRAIN[c[1],c[2]+1] in ACCESSIBLE[c[3]]) {
                DISTANCES[d+1][c[1],c[2]+1,c[3]] = path "d"
            }
        }
    }
    aoc::compute_error("no solution found in " DISTANCE_LIMIT " minutes")
}
