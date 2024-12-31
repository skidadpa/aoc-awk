#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function print_map(   x, y, coords) {
    for (y = TOP; y <= BOTTOM; ++y) {
        for (x = LEFT; x <= RIGHT; ++x) {
            coords = (x SUBSEP y)
            if (coords in WALLS) {
                printf("#")
            } else if (coords in BOXES) {
                printf("O")
            } else if (coords == ROBOT) {
                printf("@")
            } else {
                printf(".")
            }
        }
        printf("\n")
    }
}
function step(coords, m,   c) {
    split(coords, c, SUBSEP)
    if (DEBUG > 2) {
        printf("....step from (%d,%d)", c[1], c[2])
    }
    switch (m) {
    case "<":
        --c[1]
        break
    case ">":
        ++c[1]
        break
    case "^":
        --c[2]
        break
    case "v":
        ++c[2]
        break
    default:
        aoc::compute_error("unrecognized move " m)
    }
    if (DEBUG > 2) {
        printf(" to (%d,%d)\n", c[1], c[2])
    }
    return (c[1] SUBSEP c[2])
}
function can_robot_move(m,   pos) {
    pos = step(ROBOT, m)
    while (pos in BOXES) {
        pos = step(pos, m)
    }
    return (!(pos in WALLS))
}
function move_robot(m,   pos) {
    ROBOT = step(ROBOT, m)
    if (ROBOT in BOXES) {
        if (DEBUG > 2) {
            print "...moving boxes"
        }
        delete BOXES[ROBOT]
        pos = step(ROBOT, m)
        while (pos in BOXES) {
            pos = step(pos, m)
        }
        BOXES[pos] = 1
        if (pos in WALLS) {
            aoc::compute_error("pushed box into a wall")
        }
    }
    if (ROBOT in WALLS) {
        aoc::compute_error("robot ran into a wall")
    }
}
BEGIN {
    DEBUG = 0
    FS = ""
}
/^#+$/ {
    if (!TOP) {
        TOP = NR
        LEFT = 1
        RIGHT = NF
        if (TOP != 1) {
            aoc::data_error("first top not at line 1")
        }
    } else if (NF != RIGHT) {
        aoc::data_error("bottom width " NF " instead of " RIGHT)
    } else if (!BOTTOM) {
        BOTTOM = NR
    } else {
        aoc::data_error("second bottom")
    }
    for (i = 1; i <= NF; ++i) {
        WALLS[i,NR] = 1
    }
    next
}
/^#[.#@O]+#$/ {
    if (!TOP) {
        aoc::data_error("map data before top")
    } else if (BOTTOM) {
        aoc::data_error("map data after bottom")
    } else if (NF != RIGHT) {
        aoc::data_error("map width " NF " instead of " RIGHT)
    }
    for (i = 1; i <= NF; ++i) {
        switch ($i) {
        case "#":
            WALLS[i,NR] = 1
            break
        case "O":
            BOXES[i,NR] = 1
            break
        case "@":
            ROBOT = (i SUBSEP NR)
            break
        case ".":
            break
        default:
            aoc::data_error("unrecognized square " $i)
        }
    }
    next
}
/^$/ {
    if (!BOTTOM) {
        aoc::data_error("divider seen with no bottom")
    }
    next
}
/^[<>^v]+$/ {
    for (i = 1; i <= NF; ++i) {
        MOVES[++num_moves] = $i
    }
    next
}
{
    aoc::data_error()
}
END {
    if (!num_moves) {
        aoc::error("DATA ERROR: no moves detected")
    }
    if (num_moves != length(MOVES)) {
        aoc::compute_error("illegal move array")
    }
    if (DEBUG) {
        print "At start:"
        print_map()
        split(ROBOT, c, SUBSEP)
        printf("Robot starting at (%d,%d), processing %d moves\n", c[1], c[2], num_moves)
    }
    for (i = 1; i <= num_moves; ++i) {
        if (DEBUG > 1) {
            print "Move", i, ":", MOVES[i]
        }
        if (can_robot_move(MOVES[i])) {
            if (DEBUG > 1) {
                print "...can move robot"
            }
            move_robot(MOVES[i])
        }
    }
    if (DEBUG) {
        print "At end:"
        print_map()
    }
    gps_sum = 0
    for (coords in BOXES) {
        split(coords, c, SUBSEP)
        gps_sum += 100 * (c[2] - TOP) + (c[1] - LEFT)
    }
    print gps_sum
}
