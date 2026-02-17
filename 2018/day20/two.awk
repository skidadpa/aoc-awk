#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function move(loc, m,   c1, c2, new_loc) {
    split(loc, c1, ",")
    split(MOVES[m], c2, ",")
    new_loc = (c1[1] + c2[1]) "," (c1[2] + c2[2])
    if (DEBUG > 1) {
        print loc, "is adjacent to", new_loc > DFILE
    }
    ADJACENT[loc][new_loc] = ADJACENT[new_loc][loc] = 1
    return new_loc
}
function build_map(loc, path, end_points,   idx, new_loc) {
    idx = 1
    ch = substr(path,idx,1)
    if (ch in MOVES) {
        new_loc = move(loc, ch)
        ++idx
        ch = substr(path,idx,1)
    }
    return idx - 1
}
BEGIN {
    FS = ""
    MOVES["N"] = "0,-1"
    MOVES["S"] = "0,1"
    MOVES["W"] = "-1,0"
    MOVES["E"] = "1,0"
    PROCINFO["sorted_in"] = "@ind_num_asc"
}
$0 !~ /^\^[NSEW(|)]+\$$/ { aoc::data_error() }
{
    if (DEBUG) {
        print > DFILE
    }
    split("", ACTIONS)
    split("", PRIOR_MOVES)
    split("", DEST)
    split("", FORKS)
    split("", CASES)
    level = 0
    moves = ""
    for (i = 1; i <= NF; ++i) {
        switch ($i) {
        case "N":
        case "S":
        case "E":
        case "W":
            moves = moves $i
            break
        case "^":
        case "(":
            ACTIONS[i] = "fork"
            PRIOR_MOVES[i] = moves
            moves = ""
            FORKS[++level] = i
            break
        case "|":
            ACTIONS[i] = "case"
            PRIOR_MOVES[i] = moves
            moves = ""
            CASES[FORKS[level]][i] = 1
            break
        case ")":
        case "$":
            ACTIONS[i] = "join"
            PRIOR_MOVES[i] = moves
            moves = ""
            for (c in CASES[FORKS[level]]) {
                DEST[c] = i
            }
            delete CASES[FORKS[level]]
            delete FORKS[level]
            --level
            break
        default:
            aoc::data_error("unexpected move " $i " at " i)
        }
    }
    if (level != 0) {
        aoc::data_error("nesting mismatch in rule")
    }
    split("", LAST)
    split("", LOCATIONS)
    level = 0
    LAST[level] = 0
    LOCATIONS[LAST[level]]["0,0"] = 1
    split("", ADJACENT)
    for (i in ACTIONS) {
        switch (ACTIONS[i]) {
        case "fork":
            for (l in LOCATIONS[LAST[level]]) {
                loc = l
                for (m = 1; m <= length(PRIOR_MOVES[i]); ++m) {
                    loc = move(loc, substr(PRIOR_MOVES[i],m,1))
                }
                LOCATIONS[i][loc] = 1
            }
            LAST[level] = i
            LAST[++level] = i
            break
        case "case":
            for (l in LOCATIONS[LAST[level]]) {
                loc = l
                for (m = 1; m <= length(PRIOR_MOVES[i]); ++m) {
                    loc = move(loc, substr(PRIOR_MOVES[i],m,1))
                }
                LOCATIONS[DEST[i]][loc] = 1
            }
            LAST[level] = LAST[level - 1]
            break
        case "join":
            for (l in LOCATIONS[LAST[level]]) {
                loc = l
                for (m = 1; m <= length(PRIOR_MOVES[i]); ++m) {
                    loc = move(loc, substr(PRIOR_MOVES[i],m,1))
                }
                LOCATIONS[i][loc] = 1
            }
            delete LAST[level]
            LAST[--level] = i
            break
        default:
            aoc::compute_error("unknown action " ACTIONS[i])
        }
    }
    split("", VISITED)
    split("", DISTANCES)
    DISTANCES[0]["0,0"] = VISITED["0,0"] = 1
    furthest = 0
    distance = 0
    while (length(DISTANCES[distance]) > 0) {
        furthest = distance++
        for (room in DISTANCES[furthest]) {
            for (next_room in ADJACENT[room]) if (!(next_room in VISITED)) {
                if (DEBUG) {
                    print "visiting", room > DFILE
                }
                DISTANCES[distance][next_room] = VISITED[next_room] = 1
            }
        }
    }
    sum = 0
    for (i = 1000; i <= furthest; ++i) {
        sum += length(DISTANCES[i])
    }
    print sum
}
