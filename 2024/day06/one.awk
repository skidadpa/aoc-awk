#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FS = ""
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3
    DX[UP] = DX[DOWN] = DY[LEFT] = DY[RIGHT] = 0
    DX[LEFT] = DY[UP] = -1
    DX[RIGHT] = DY[DOWN] = 1
    DIRS = 4
}
{
    for (i = 1; i <= NF; ++i) {
        MAP[i,NR] = $i
        if ($i == "#") {
            OBSTACLES[i,NR] = 1
        } else if ($i == "^") {
            MAP[i,NR] = "."
            x = i
            y = NR
            dir = UP
        } else if ($i != ".") {
            aoc::data_error("Invalid square " $i)
        }
    }
    height = NR
    width = NF
}
END {
    if (DEBUG) {
        print "MAP:"
        for (iy = 1; iy <= height; ++iy) {
            for (ix = 1; ix <= width; ++ix) {
                printf("%c", MAP[ix,iy])
            }
            printf("\n")
        }
        print "start: x =", x, "y =", y, "dir = UP"
    }
    while ((x SUBSEP y) in MAP) {
        ++VISITED[x,y]
        for (i = 0; i < DIRS; ++i) {
            nx = x + DX[dir]
            ny = y + DY[dir]
            if ((nx SUBSEP ny) in OBSTACLES) {
                dir = (dir + 1) % DIRS
            } else {
                break
            }
        }
        if (i >= DIRS) {
            aoc::compute_error("no moves at " x "," y)
        }
        x = nx
        y = ny
    }
    print length(VISITED)
}
