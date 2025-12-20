#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0

    FS = ""

    RIGHT = 0
    DOWN = 1
    LEFT = 2
    UP = 3

    split("", TURN["."])
    split("", SPLIT["."])

    TURN["/"][RIGHT] = UP
    TURN["/"][DOWN] = LEFT
    TURN["/"][LEFT] = DOWN
    TURN["/"][UP] = RIGHT
    split("", SPLIT["/"])

    TURN["\\"][RIGHT] = DOWN
    TURN["\\"][DOWN] = RIGHT
    TURN["\\"][LEFT] = UP
    TURN["\\"][UP] = LEFT
    split("", SPLIT["\\"])

    TURN["|"][RIGHT] = DOWN
    TURN["|"][LEFT] = UP
    SPLIT["|"][RIGHT] = UP
    SPLIT["|"][LEFT] = DOWN

    TURN["-"][DOWN] = LEFT
    TURN["-"][UP] = RIGHT
    SPLIT["-"][DOWN] = RIGHT
    SPLIT["-"][UP] = LEFT

    split("", splitter_starts)
    SPLIT_START["|"] = RIGHT
    SPLIT_START["-"] = DOWN
}
!width { width = NF }
width != NF {
    aoc::data_error("width changed from " width " to " NF)
}
$0 !~ /^[-|./\\]+$/ {
    aoc::data_error()
}
{
    for (c = 1; c <= NF; ++c) {
        grid[c,NR] = $c
        if ($c in SPLIT_START) {
            splitter_starts[c,NR] = SPLIT_START[$c]
        }
    }
}
function move(loc, direction,   coords) {
    split(loc, coords, SUBSEP)
    switch (direction) {
        case "0": # RIGHT
            ++coords[1]
            break
        case "1": # DOWN
            ++coords[2]
            break
        case "2": # LEFT
            --coords[1]
            break
        case "3": # UP
            --coords[2]
            break
        default:
            aoc::compute_error("bad direction " direction)
    }
    return coords[1] SUBSEP coords[2]
}
function coordinates(loc,   coords) {
    split(loc, coords, SUBSEP)
    return "(" coords[1] "," coords[2] ")"
}
function facing(direction) {
    switch (direction) {
        case "0": # RIGHT
            return "RIGHT"
        case "1": # DOWN
            return "DOWN"
        case "2": # LEFT
            return "LEFT"
        case "3": # UP
            return "UP"
    }
    aoc::compute_error("bad direction " direction)
}
END {
    height = NR
    if (DEBUG) {
        print "calculating splitter effects"
    }
    split("", splitter_energizes)
    for (splitter_location in splitter_starts) {
        split("", starting_direction)
        split("", starting_location)
        nbeams = 0
        starting_direction[++nbeams] = splitter_starts[splitter_location]
        starting_location[nbeams] = splitter_location
        split("", energized)
        split("", visited)
        for (beam = 1; beam <= nbeams; ++beam) {
            direction = starting_direction[beam]
            location = starting_location[beam]
            if (DEBUG > 2) {
                print "beam", beam, "facing", facing(direction), "at", coordinates(location)
            }
            while (location in grid) {
                if (DEBUG > 2) {
                    print " energizing", coordinates(location)
                }
                energized[location] = 1
                if ((location SUBSEP direction) in visited) {
                    location = 0 SUBSEP 0
                    continue
                }
                visited[location, direction] = 1
                tile = grid[location]
                if (direction in SPLIT[tile]) {
                    if (location in splitter_energizes) {
                        for (e in splitter_energizes[location]) {
                            energized[e] = 1
                        }
                        location = 0 SUBSEP 0
                        continue
                    }
                    new_direction = SPLIT[tile][direction]
                    new_location = move(location, new_direction)
                    starting_direction[++nbeams] = new_direction
                    starting_location[nbeams] = new_location
                    if (DEBUG > 2) {
                        print " new beam", nbeams, "facing", facing(new_direction), "at", coordinates(new_location)
                    }
                }
                if (direction in TURN[tile]) {
                    direction = TURN[tile][direction]
                    if (DEBUG > 2) {
                        print " turning", facing(direction)
                    }
                }
                location = move(location, direction)
                if (DEBUG > 2) {
                    print " moving to", coordinates(location)
                }
            }
        }
        for (e in energized) {
            splitter_energizes[splitter_location][e] = 1
        }
    }
    nstarts = 0
    for (r = 1; r <= height; ++r) {
        entry_direction[++nstarts] = RIGHT
        entry_location[nstarts] = 1 SUBSEP r
        entry_direction[++nstarts] = LEFT
        entry_location[nstarts] = width SUBSEP r
    }
    for (c = 1; c <= width; ++c) {
        entry_direction[++nstarts] = DOWN
        entry_location[nstarts] = c SUBSEP 1
        entry_direction[++nstarts] = UP
        entry_location[nstarts] = c SUBSEP height
    }
    if (DEBUG) {
        print "checking all starts"
    }
    max_energized = 0
    for (start = 1; start <= nstarts; ++start) {
        split("", starting_direction)
        split("", starting_location)
        nbeams = 0
        starting_direction[++nbeams] = entry_direction[start]
        starting_location[nbeams] = entry_location[start]
        split("", energized)
        split("", visited)
        for (beam = 1; beam <= nbeams; ++beam) {
            direction = starting_direction[beam]
            location = starting_location[beam]
            if (DEBUG > 1) {
                print "beam", beam, "facing", facing(direction), "at", coordinates(location)
            }
            while (location in grid) {
                if (DEBUG > 1) {
                    print " energizing", coordinates(location)
                }
                energized[location] = 1
                if ((location SUBSEP direction) in visited) {
                    location = 0 SUBSEP 0
                    continue
                }
                visited[location, direction] = 1
                tile = grid[location]
                if (direction in SPLIT[tile]) {
                    if (!(location in splitter_energizes)) {
                        aoc::compute_error("splitter not found at " coordinates(location))
                    }
                    for (e in splitter_energizes[location]) {
                        energized[e] = 1
                    }
                    if (DEBUG > 1) {
                        print " splitter encountered at", coordinates(new_location)
                    }
                    location = 0 SUBSEP 0
                    continue
                }
                if (direction in TURN[tile]) {
                    direction = TURN[tile][direction]
                    if (DEBUG > 1) {
                        print " turning", facing(direction)
                    }
                }
                location = move(location, direction)
                if (DEBUG > 1) {
                    print " moving to", coordinates(location)
                }
            }
        }

        if (DEBUG > 1) {
            print "ENERGIZED TILES:"
            for (r = 1; r <= height; ++r) {
                for (c = 1; c <= width; ++c) {
                    printf("%s", ((c SUBSEP r) in energized) ? "#" : ".")
                }
                printf("\n")
            }
        }
        if (max_energized < length(energized)) {
            max_energized = length(energized)
        }
        if (DEBUG) {
            print start, ": starting", facing(entry_direction[start]), "at", coordinates(entry_location[start]), "energizes", length(energized), "max is", max_energized
        }
    }
    print max_energized
}
