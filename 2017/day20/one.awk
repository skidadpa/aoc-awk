#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
    triplet = "<" FPAT "," FPAT "," FPAT ">"
    LINE_MATCH = "^p=" triplet ", v=" triplet ", a=" triplet "$"
    STEPS = 1000
    DEBUG = 0
}
$0 !~ LINE_MATCH { aoc::data_error() }
{
    PX[NR] = $1
    VX[NR] = $4
    AX[NR] = $7
    PY[NR] = $2
    VY[NR] = $5
    AY[NR] = $8
    PZ[NR] = $3
    VZ[NR] = $6
    AZ[NR] = $9
}
END {
    # cheesy but fast, let's see if it's sufficient:
    for (step = 1; step < STEPS; ++step) {
        for (i = 1; i <= NR; ++i) {
            PX[i] += VX[i]
            VX[i] += AX[i]
            PY[i] += VY[i]
            VY[i] += AY[i]
            PZ[i] += VZ[i]
            VZ[i] += AZ[i]
        }
    }
    closest = 1
    for (i = 1; i <= NR; ++i) {
        DIST[i] = aoc::abs(PX[i]) + aoc::abs(PY[i]) + aoc::abs(PZ[i])
        if (DIST[closest] > DIST[i]) {
            closest = i
        }
        if (DEBUG) {
            print "After " STEPS, "steps, Manhattan distance for particle", i - 1, "is", DIST[i] > DFILE
        }
    }

    # particle numbers are actually 0-based...
    print closest - 1
}
