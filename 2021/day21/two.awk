#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
($0 ~! /^Player [1-2] starting position: [0-9]$/) { aoc::data_error() }
{ space[$2] = $5+0 }
function ssss(u, p2, r,    p, s) {
    space1 = and(rshift(u, 16), 0xf)
    score1 = and(rshift(u, 20), 0xff)
    space2 = and(rshift(u, 12), 0xf)
    score2 = and(u,             0xff)
    if (p2) {
        space2 += r; if (space2 > 10) space2 -= 10
        score2 += space2
        if (score2 >= 21) return -2
    } else {
        space1 += r; if (space1 > 10) space1 -= 10
        score1 += space1
        if (score1 >= 21) return -1
    }
    return lshift(score1, 20) + lshift(space1, 16) + lshift(space2, 12) + score2
}
END {
    for (a1 = 1; a1 <= 3; ++a1) for (a2 = 1; a2 <= 3; ++a2) for (a3 = 1; a3 <= 3; ++a3) ++rolls[a1+a2+a3]
    universe[0][space[1] * 0x10000 + space[2] * 0x1000 ] = 1
    for (step = 0; step < 40 && length(universe[step]); ++step) {
        # print "expanding step", step, ":", length(universe[step]) > DFILE
        for (u in universe[step]) if (u > 0) for (r in rolls)
            universe[step+1][ssss(u, step % 2, r)] += universe[step][u] * rolls[r]
    }
    if (length(universe[step])) { aoc::compute_error() }
    delete universe[step]
    for (step in universe) {
        # for (u in universe[step]) printf "step %u: %08x : %u\n", step, u, universe[step][u] > DFILE
        p1winner += universe[step][-1]
        p2winner += universe[step][-2]
    }
    # print "Player 1 wins in", p1winner, "universes" > DFILE
    # print "Player 2 wins in", p2winner, "universes" > DFILE
    print (p1winner > p2winner) ? p1winner : p2winner
}
