#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    START = 1 SUBSEP 1
    DEST = 31 SUBSEP 39
    LIMIT = 50
}
/^SAMPLE SET$/ {
    DEST = 7 SUBSEP 4
    next
}
$0 !~ /^[[:digit:]]+$/ {
    aoc::data_error()
}
function odd_one_bits(x,   c) {
    c = 0
    while (x) {
        c = xor(c, and(x,1))
        x = rshift(x,1)
    }
    return c
}
function dump() {
    for (y = -1; y <= LIMIT + 1; ++y) {
        for (x = -1; x <= LIMIT + 1; ++x) {
            if ((x,y) in WALLS) {
                printf("#") > DFILE
            } else if ((x,y) in PATHS) {
                printf("%d", PATHS[x,y] % 10) > DFILE
            } else if ((x,y) in DESTS) {
                printf("%d", DESTS[x,y] % 10) > DFILE
            } else {
                printf(".") > DFILE
            }
        }
        printf("\n") > DFILE
    }
}
function find_moves(c, M, val,   XY) {
    split("", M)
    split(c, XY, SUBSEP)
    M[XY[1]-1,XY[2]] = M[XY[1],XY[2]+1] = M[XY[1]+1,XY[2]] = M[XY[1],XY[2]-1] = val
}
{
    PATHS[START] = FORWARD[0][START] = 0
    for (i = 0; i <= LIMIT; ++i) {
        WALLS[-1,i] = WALLS[i,-1] = WALLS[LIMIT+1,i] = WALLS[i,LIMIT+1] = 1
        LIMITS[LIMIT,i] = LIMITS[i,LIMIT] = 1
    }
    for (x = 0; x < LIMIT; ++x) for (y = 0; y < LIMIT; ++y) {
        if (odd_one_bits(x*x + 3*x + 2*x*y + y + y*y + $1)) {
            WALLS[x,y] = 1
        }
    }
    if (DEBUG) {
        print "at start:" > DFILE
        dump()
    }
    for (i = 0; i < 50; ++i) {
        for (c in FORWARD[i]) {
            find_moves(c, MOVES, i+1)
            for (m in MOVES) {
                if (!(m in WALLS) && !(m in PATHS)) {
                    FORWARD[i+1][m] = PATHS[m] = MOVES[m]
                }
            }
        }
        if (DEBUG) {
            print "after turn", i+1 > DFILE
            dump()
        }
    }
    print length(PATHS)
}
