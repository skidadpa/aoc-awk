#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
    WIDTH = 0
    m1 = "" -1
    LEFT[0,m1] = m1 SUBSEP 0
    LEFT[m1,0] = 0 SUBSEP 1
    LEFT[0,1] = 1 SUBSEP 0
    LEFT[1,0] = 0 SUBSEP m1
    for (d in LEFT) {
        RIGHT[LEFT[d]] = d
    }
    REVERSE[0,m1] = 0 SUBSEP 1
    REVERSE[m1,0] = 1 SUBSEP 0
    REVERSE[0,1] = 0 SUBSEP m1
    REVERSE[1,0] = m1 SUBSEP 0
    ARROWS[0,m1] = "^"
    ARROWS[m1,0] = "<"
    ARROWS[0,1] = "v"
    ARROWS[1,0] = ">"
}
$0 !~ /^[.#]+$/ { aoc::data_error() }
(!WIDTH) {
    WIDTH = NF
    OFFSET = int((WIDTH + 1)/ 2)
}
(WIDTH != NF) { aoc::data_error("width changed from " WIDTH " to " NF) }
{
    for (i = 1; i <= NF; ++i) {
        if ($i == "#") {
            INFECTED[(i - OFFSET),(NR - OFFSET)] = 1
        }
    }
}
function dump(left, right, top, bottom, p, d,   x, y, idx, line) {
    for (y = top; y <= bottom; ++y) {
        line = ""
        for (x = left; x <= right; ++x) {
            idx = x SUBSEP y
            if (p == idx) {
                line = line ((idx in INFECTED) ? "i" : (idx in WEAKENED) ? "w" : (idx in FLAGGED) ? "f" : ARROWS[d])
            } else if (idx in INFECTED) {
                line = line "#"
            } else if (idx in WEAKENED) {
                line = line "W"
            } else if (idx in FLAGGED) {
                line = line "F"
            } else {
                line = line "."
            }
        }
        print line > DFILE
    }
}
END {
    if (NR != WIDTH) {
        aoc::data_error("height " NR " does not match width " WIDTH)
    }
    pos = 0 SUBSEP 0
    dir = 0 SUBSEP m1
    if (DEBUG) {
        print pos, dir, ARROWS[dir] > DFILE
        dump(-10,10,-10,10,pos,dir)
    }
    if (DEBUG > 10) {
        print "ARROWS"
        for (d in ARROWS) {
            split(d, xy, SUBSEP)
            print xy[1] "," xy[2], ARROWS[d]
        }
        print "LEFT"
        for (d in LEFT) {
            split(d, xyfrom, SUBSEP)
            split(LEFT[d], xyto, SUBSEP)
            print xyfrom[1] "," xyfrom[2], "->", xyto[1] "," xyto[2]
        }
        print "RIGHT"
        for (d in RIGHT) {
            split(d, xyfrom, SUBSEP)
            split(RIGHT[d], xyto, SUBSEP)
            print xyfrom[1] "," xyfrom[2], "->", xyto[1] "," xyto[2]
        }
    }
    num_infected = 0
    BURST_LIMIT = 10000000
    for (burst = 1; burst <= BURST_LIMIT; ++burst) {
        if (pos in INFECTED) {
            dir = RIGHT[dir]
            delete INFECTED[pos]
            FLAGGED[pos] = 1
        } else if (pos in WEAKENED) {
            delete WEAKENED[pos]
            INFECTED[pos] = 1
            ++num_infected
        } else if (pos in FLAGGED) {
            dir = REVERSE[dir]
            delete FLAGGED[pos]
        } else {
            dir = LEFT[dir]
            WEAKENED[pos] = 1
        }
        split(pos SUBSEP dir, TEMP, SUBSEP)
        pos = (TEMP[1] + TEMP[3]) SUBSEP (TEMP[2] + TEMP[4])
        if (DEBUG) {
            print "total infected:", num_infected > DFILE
            dump(-10,10,-10,10,pos,dir)
        }
    }
    print num_infected
}
