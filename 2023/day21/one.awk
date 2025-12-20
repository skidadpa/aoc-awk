#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
    directions["E"] = directions["S"] = directions["W"] = directions["N"] = 1
}
$0 !~ /^[.#S]+$/ {
    aoc::data_error()
}
!width { width = NF }
(width != NF) {
    aoc::data_error("saw width " NF ", expected " width)
}
{
    for (c = 1; c <= NF; ++c) {
        switch ($c) {
            case "S":
                steps[0][c,NR] = 1
            case ".":
                garden[c,NR] = 1
                break
            case "#":
                break
            default:
                aoc::data_error("unexpected code " $c)
        }
    }
}
function move(from, dir,   coords) {
    split(from, coords, SUBSEP)
    switch (dir) {
        case "E":
            return ((coords[1] + 1) SUBSEP coords[2])
        case "S":
            return (coords[1] SUBSEP (coords[2] + 1))
        case "W":
            return ((coords[1] - 1) SUBSEP coords[2])
        case "N":
            return (coords[1] SUBSEP (coords[2] - 1))
        default:
            aoc::compute_error("unknown direction " dir)
    }
}
END {
    if (!length(steps[0])) {
        aoc::compute_error("no starting position found")
    }
    num_steps = (width < 12) ? 6 : 64
    for (step = 0; step < num_steps; ++step) {
        for (pos in steps[step]) {
            for (dir in directions) {
                new_pos = move(pos, dir)
                if (new_pos in garden) {
                    steps[step + 1][new_pos] = 1
                }
            }
        }
    }
    print length(steps[step])
}
