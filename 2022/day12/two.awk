#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    num_codes = split("abcdefghijklmnopqrstuvwxyz", elevation_codes, "")
    for (e = 1; e <= num_codes; ++e) {
        elevation[elevation_codes[e]] = e
    }
}
/S/ {
    # S = NR SUBSEP index($0, "S")
    sub("S","a")
}
/E/ {
    E = NR SUBSEP index($0, "E")
    sub("E","z")
}
/^[a-z]+$/ {
    row_width = split($0, row, "")
    if (!width) {
        width = row_width
    }
    if (width != row_width) {
        aoc::data_error()
    }
    for (i = 1; i <= width; ++i) {
        MAP[NR,i] = elevation[row[i]]
        if (row[i] == "a") {
            POSSIBLE_STARTS[NR,i] = 0
        }
    }
    next
}
{
    aoc::data_error()
}
function print_location(location, ll) {
    split(location, ll, SUBSEP)
    print "row", ll[1], "col", ll[2] > DFILE
}
function try_these(location, places_to_try,   ll) {
    split(location, ll, SUBSEP)
    split("", places_to_try)
    places_to_try[(ll[1] - 1),ll[2]] = 1
    places_to_try[(ll[1] + 1),ll[2]] = 1
    places_to_try[ll[1],(ll[2] - 1)] = 1
    places_to_try[ll[1],(ll[2] + 1)] = 1
}
function find_moves(from, dist,   places, p) {
    try_these(from, places)
    for (p in places) {
        if ((p in MAP) && (MAP[p] <= MAP[from] + 1) && (!(p in DISTANCE))) {
            DISTANCE[p] = dist
            if (p == E) {
                return 1
            } else {
                MOVES[dist][p] = 1
            }
        }
    }
    return 0
}
function find_distance(S,   last_dist, dist, location) {
    delete DISTANCE
    delete MOVES
    DISTANCE[S] = 0
    MOVES[0][S] = 1
    for (last_dist = 0; last_dist < 10000; ++last_dist) {
        dist = last_dist + 1
        if (DEBUG > 1) {
            print "Trying distance of", dist > DFILE
        }
        for (location in MOVES[last_dist]) {
            if (DEBUG > 1) {
                printf("Moves from ") > DFILE
                print_location(location)
            }
            if (find_moves(location, dist)) {
                return dist
            }
        }
    }
    return 999999
}
END {
    height = NR
    if (DEBUG) {
        printf("start at ") > DFILE
        print_location(S)
        printf("end at ") > DFILE
        print_location(E)
        for (r = 1; r <= height; ++r) {
            for (c = 1; c <= width; ++c) {
                printf("%c", elevation_codes[MAP[r,c]]) > DFILE
            }
            printf("\n") > DFILE
        }
    }
    for (S in POSSIBLE_STARTS) {
        if (DEBUG) {
            printf("Finding distance of ") > DFILE
            print_location(S)
        }
        DISTANCES[S] = find_distance(S)
    }
    asort(DISTANCES, BEST_DISTANCES, "@val_num_asc")
    print BEST_DISTANCES[1]
}
