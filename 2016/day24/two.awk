#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
}
(!WIDTH) {
    WIDTH = NF
}
(WIDTH != NF) {
    aoc::data_error("expecting WIDTH " WIDTH)
}
($0 !~ /^[#.[:digit:]]+$/) {
    aoc::data_error("CONTAINS ILLEGAL VALUES")
}
{
    for (i = 1; i <= NF; ++i) {
        # MAP[i,NR] = $i
        if ($i == "#") {
            WALLS[i,NR] = 1
        } else if ($i ~ /[[:digit:]]/) {
            LOCATIONS[$i] = i SUBSEP NR
        }
    }
}
function find_next_targets(d, l, coords,   COORDS, x, y) {
    if (DEBUG > 5) {
        print "Distance", d, "with", length(TARGETS), "targets remaining:" > DFILE
    }
    for (coords in PATHS[d]) {
        if (DEBUG > 5) {
            split(coords, COORDS, SUBSEP)
            printf(" %d,%d", COORDS[1], COORDS[2]) > DFILE
        }
        if ((coords in DISTANCE[l]) || (coords in WALLS)) {
            if (DEBUG > 5) {
                printf("x") > DFILE
            }
            continue
        }
        DISTANCE[l][coords] = d
        if (coords in TARGETS) {
            if (DEBUG > 5) {
                printf("*") > DFILE
            }
            if (!(TARGETS[coords] in SHORTEST_PATH[l])) {
                SHORTEST_PATH[l][TARGETS[coords]] = d
            }
            delete TARGETS[coords]
        }
        split(coords, COORDS, SUBSEP)
        x = int(COORDS[1])
        y = int(COORDS[2])
        PATHS[d+1][x-1,y] = d+1
        PATHS[d+1][x,y-1] = d+1
        PATHS[d+1][x+1,y] = d+1
        PATHS[d+1][x,y+1] = d+1
    }
    if (DEBUG > 5) {
        printf("\n") > DFILE
        print length(PATHS[d+1]), "new paths to try" > DFILE
    }
}
function route_distance(path,   distance, i) {
    if (DEBUG > 2) {
        printf("distance of %s is 0", path) > DFILE
    }
    distance = 0
    for (i = 1; i < length(path); ++i) {
        if (DEBUG > 2) {
            printf(" + %s", SHORTEST_PATH[substr(path,i,1)][substr(path,i+1,1)]) > DFILE
        }
        distance += SHORTEST_PATH[substr(path,i,1)][substr(path,i+1,1)]
    }
    if (DEBUG > 2) {
        printf(" = %d\n", distance) > DFILE
    }
    return distance
}
function find_all_permutations_from(path, nxt, PLACES,   p, NEXT_PLACES) {
    split("", NEXT_PLACES)
    for (p in PLACES) {
        if (p == nxt) {
            path = path nxt
        } else {
            NEXT_PLACES[p] = PLACES[p]
        }
    }
    if (length(NEXT_PLACES)) {
        for (p in NEXT_PLACES) {
            find_all_permutations_from(path, p, NEXT_PLACES)
        }
    } else {
        path = path "0"
        ROUTES[path] = route_distance(path)
        if (!shortest_route || (ROUTES[shortest_route] > ROUTES[path])) {
            shortest_route = path
        }
    }
}
END {
    for (l in LOCATIONS) {
        if (DEBUG > 1) {
            print "finding distances to all locations from", l > DFILE
        }
        for (t in LOCATIONS) {
            TARGETS[LOCATIONS[t]] = t
        }
        delete PATHS
        PATHS[0][LOCATIONS[l]] = 0
        for (d = 0; length(TARGETS) && length(PATHS[d]); ++d) {
            find_next_targets(d, l)
        }
        if (length(TARGETS)) {
            aoc::compute_error("quit with " length(TARGETS) " remaining targets from " l)
        }
    }
    if (DEBUG > 1) {
        print "shortest paths:" > DFILE
        for (l in LOCATIONS) {
            for (d in SHORTEST_PATH[l]) {
                print l, "->", d, "=", SHORTEST_PATH[l][d] > DFILE
            }
        }
    }
    find_all_permutations_from("", "0", LOCATIONS)
    if (DEBUG > 1) {
        print "routes:" > DFILE
        for (r in ROUTES) {
            print r, ":", ROUTES[r] > DFILE
        }
    }
    if (DEBUG) {
        print "shortest route:", shortest_route > DFILE
    }
    print ROUTES[shortest_route]
}
