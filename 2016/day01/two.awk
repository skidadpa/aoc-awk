#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "([LR])|([[:digit:]]+)"
    LEFT["N"] = "W"
    LEFT["S"] = "E"
    LEFT["E"] = "N"
    LEFT["W"] = "S"
    RIGHT["N"] = "E"
    RIGHT["S"] = "W"
    RIGHT["E"] = "S"
    RIGHT["W"] = "N"
    XMUL["N"] = 0
    XMUL["S"] = 0
    XMUL["E"] = 1
    XMUL["W"] = -1
    YMUL["N"] = -1
    YMUL["S"] = 1
    YMUL["E"] = 0
    YMUL["W"] = 0
}
function abs(x) { return x < 0 ? -x : x }
$0 !~ /^[LR][[:digit:]]+(, [LR][[:digit:]]+)*$/ {
    aoc::data_error()
}
{
    dir = "N"
    x = y = 0
    MOVES[x,y] = 1
    if (DEBUG) { print "start at", x, y, "facing", dir > DFILE }
    for (t = 1; t < NF; t += 2) {
        d = t + 1
        switch ($t) {
        case "L":
            dir = LEFT[dir]
            break
        case "R":
            dir = RIGHT[dir]
            break
        default:
            aoc::compute_error($t)
        }
        if (DEBUG) { print "turn", $t, "and move", $d, "to face", dir > DFILE }
        for (i = 1; i <= $d; ++i) {
            x += XMUL[dir]
            y += YMUL[dir]
            if ((x,y) in MOVES) {
                if (DEBUG) { print "hit location", x, y, "which has been previously visited" }
                print abs(x) + abs(y)
                next
            }
            MOVES[x,y] = 1
        }
        if (DEBUG) { print "ended move at location", x, y }
    }
    aoc::compute_error("no moves duplicated")
}
