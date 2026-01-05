#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
@load "./md5"
BEGIN {
    OPEN["b"] = OPEN["c"] = OPEN["d"] = OPEN["e"] = OPEN["f"] = 1
    UP = 1
    DOWN = 2
    LEFT = 3
    RIGHT = 4
    CH[UP] = "U"
    CH[DOWN] = "D"
    CH[LEFT] = "L"
    CH[RIGHT] = "R"
    YCOORD = 1
    XCOORD = 2
    LIMIT = 10000000
}
{
    delete MOVES
    seed = $0
    hash = md5(seed)
    if (substr(hash, DOWN, 1) in OPEN) {
        MOVES[1][CH[DOWN]] = "21"
    }
    if (substr(hash, RIGHT, 1) in OPEN) {
        MOVES[1][CH[RIGHT]] = "12"
    }
    for (path_len = 1; path_len <= LIMIT; ++path_len) {
        if (DEBUG) {
            print "trying paths of length", path_len > DFILE
        }
        for (path in MOVES[path_len]) {
            y = substr(MOVES[path_len][path], YCOORD, 1)
            x = substr(MOVES[path_len][path], XCOORD, 1)
            hash = md5(seed path)
            if ((y < 4) && (substr(hash, DOWN, 1) in OPEN)) {
                MOVES[path_len + 1][path CH[DOWN]] = (y + 1) "" x
                if (((y + 1) == 4) && (x == 4)) {
                    print path CH[DOWN]
                    next
                }
            }
            if ((x < 4) && (substr(hash, RIGHT, 1) in OPEN)) {
                MOVES[path_len + 1][path CH[RIGHT]] = y "" (x + 1)
                if ((y == 4) && ((x + 1) == 4)) {
                    print path CH[RIGHT]
                    next
                }
            }
            if ((y > 1) && (substr(hash, UP, 1) in OPEN)) {
                MOVES[path_len + 1][path CH[UP]] = (y - 1) "" x
            }
            if ((x > 1) && (substr(hash, LEFT, 1) in OPEN)) {
                MOVES[path_len + 1][path CH[LEFT]] = y "" (x - 1)
            }
        }
        delete MOVES[path_len]
    }
    if (DEBUG) {
        print "paths of length", LIMIT + 1 > DFILE
        for (path in MOVES[LIMIT + 1]) {
            print path, "at", MOVES[LIMIT + 1][path] > DFILE
        }
    }
    aoc::compute_error("no solution reached by path of length " LIMIT)
}
