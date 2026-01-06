#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
    TOP = LEFT = 99999999
    RIGHT = BOTTOM = -99999999
}
function abs(x) { return x < 0 ? -x : x }
function scanned(x,y,   coord) {
    for (s in SENSORS) {
        split(s, coord, SUBSEP)
        if (abs(x - coord[1]) + abs(y - coord[2]) <= SENSORS[s]) {
            return 1
        }
    }
    return 0
}
(NF != 4 || $0 !~ /^Sensor at x=[[:digit:]]+, y=[[:digit:]]+: closest beacon is at x=-?[[:digit:]]+, y=-?[[:digit:]]+$/) {
    aoc::data_error()
}
{
    d = abs($1 - $3) + abs($2 - $4)
    if ($1 + d > RIGHT) RIGHT = $1 + d
    if ($1 - d < LEFT) LEFT = $1 - d
    if ($2 + d > BOTTOM) BOTTOM = $2 + d
    if ($2 - d < TOP) TOP = $2 - d
    if (DEBUG) printf("[%d,%d] detected [%d,%d] at distance %d\n",$1,$2,$3,$4,d) > DFILE
    SENSORS[$1,$2] = d
    ++BEACONS[$3,$4]
}
END {
    if (DEBUG) {
        printf("%d sensors and %d beacons in [%d,%d]-[%d,%d]\n",
               length(SENSORS), length(BEACONS), LEFT, TOP, RIGHT, BOTTOM) > DFILE
    }
    row = (RIGHT > 1000) ? 2000000 : 10
    if (DEBUG) printf("%d...", LEFT) > DFILE
    for (x = LEFT; x <= RIGHT; ++x) {
        if (DEBUG) if (x % 100000 == 0) printf("%d...", x) > DFILE
        if (scanned(x, row) && !((x,row) in BEACONS)) {
            ++count
        }
    }
    if (DEBUG) printf("%d\n", RIGHT) > DFILE
    print count
}
