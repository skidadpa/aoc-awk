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
                steps[0][(c - 1),(NR - 1)] = 1
            case ".":
                garden[(c - 1),(NR - 1)] = 1
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
function normalize(from,   coords) {
    split(from, coords, SUBSEP)
    return (((coords[1] + 0) % width) SUBSEP ((coords[2] + 0) % height))
}
END {
    print "NOT IMPLEMENTED YET"
    exit
    height = NR
    if (!length(steps[0])) {
        aoc::compute_error("no starting position found")
    }
    split("", dump_points)
    if (width < 12) {
        num_steps = 5000
        dump_points[6] = dump_points[10] = dump_points[50] = dump_points[100] = dump_points[500] = dump_points[1000] = dump_points[5000] = 1
    } else {
        num_steps = 26501365
    }
    for (step = 0; step < num_steps; ++step) {
        if (step in dump_points) {
            print "after", step, "steps, can reach", length(steps[step])
        }
        for (pos in steps[step]) {
            for (dir in directions) {
                new_pos = move(pos, dir)
                if (normalize(new_pos) in garden) {
                    steps[step + 1][new_pos] = 1
                }
            }
        }
    }
    print length(steps[step])
}
