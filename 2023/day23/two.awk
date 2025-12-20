#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FS = ""
    RIGHT = ">"
    DOWN = "v"
    LEFT = "<"
    UP = "^"
    split(">v<^", dir_names, "")
    for (d in dir_names) {
        directions[dir_names[d]] = d
    }
}
$0 !~ /^[#.>v<^]+$/ {
    aoc::data_error()
}
(!width) { width = NF }
(width != NF) {
    aoc::data_error("width changed from " width " to " NF ", not supported")
}
{
    for (c = 1; c <= NF; ++c) {
        if ($c != "#") {
            if (NR == 1) {
                if (!start) {
                    start = (c SUBSEP NR)
                } else {
                    aoc::data_error("duplicate start points " coordinates(start) " and (" c "," NR ")")
                }
            } else {
                end = (c SUBSEP NR)
            }
            map[c,NR] = $c
            if ($c != ".") {
                arrows[c,NR] = $c
            }
        }
    }
}
function move(from, dir,    coords) {
    split(from, coords, SUBSEP)
    switch (dir) {
        case ">":
            return ((coords[1] + 1) SUBSEP coords[2])
        case "v":
            return (coords[1] SUBSEP (coords[2] + 1))
        case "<":
            return ((coords[1] - 1) SUBSEP coords[2])
        case "^":
            return (coords[1] SUBSEP (coords[2] - 1))
        default:
            aoc::compute_error("unrecognized direction " dir)
    }
}
function return_path(dir) {
    split(from, coords, SUBSEP)
    switch (dir) {
        case ">":
            return "<"
        case "v":
            return "^"
        case "<":
            return ">"
        case "^":
            return "v"
        default:
            aoc::compute_error("unrecognized direction " dir)
    }
}
function coordinates(loc,    coords) {
    split(loc, coords, SUBSEP)
    return "(" coords[1] "," coords[2] ")"
}
function mark_paths_from(from, forward,    moving_forward, to, back, d) {
    moving_forward = 1
    while (moving_forward) {
        back = return_path(forward)
        forward = back
        if (from in arrows) {
            forward = arrows[from]
            from = move(from, forward)
        } else if (from in forks) {
            return
        } else {
            for (d in directions) {
                if (d != back) {
                    to = move(from, d)
                    if (to in map) {
                        if (forward == back) {
                            forward = d
                        } else {
                            moving_forward = 0
                        }
                    }
                }
            }
            if (forward == back) {
                moving_forward = 0
            }
            if (moving_forward) {
                map[from] = arrows[from] = forward
                from = move(from, forward)
            }
        }
    }
    if (map[from] == ".") {
        split("", forks[from])
        for (d in directions) {
            if (d != back) {
                to = move(from, d)
                if ((to in map) && (map[to] != return_path(d))) {
                    forks[from][d] = 1
                }
            }
        }
        for (forward in forks[from]) {
            mark_paths_from(move(from, forward), forward)
        }
    } else if (map[from] != "E") {
        aoc::compute_error("stopped at non-end location")
    }
}
function dump_map(    y, x) {
    for (y = 1; y <= NR; ++y) {
        for (x = 1; x <= width; ++x) {
            if ((x SUBSEP y) in map) {
                printf("%s", map[x,y])
            } else {
                printf("#")
            }
        }
        printf("\n")
    }
    printf("\n")
}
function find_routes(node, dir, distance, path) {
    distance += node_distances[node][dir]
    node = node_ends[node][dir]
    if (node == end) {
        if (DEBUG) {
            print "FOUND PATH OF LENGTH", distance
        }
        if (longest < distance) {
            longest = distance
        }
        return
    }
    if (index(path, "(" node ")")) {
        return
    }
    path = path "(" node ")"
    for (dir in node_ends[node]) {
        find_routes(node, dir, distance, path)
    }
}
END {
    map[start] = "v"
    map[end] = "E"
    if (DEBUG) { dump_map() }
    mark_paths_from(start, "v")
    if (DEBUG) { dump_map() }
    num_combinations = 1
    forward_node_starts[start]["v"] = 1
    for (f in forks) {
        if (DEBUG) {
            print coordinates(f), ":", length(forks[f]), "forks"
        }
        num_combinations *= length(forks[f])
        for (dir in forks[f]) {
            forward_node_starts[f][dir] = 1
        }
    }
    if (DEBUG) {
        print coordinates(start), ": start"
        print coordinates(end), ": end"
        printf("\n")
    }
    if (num_combinations > 100000000) {
        aoc::compute_error("too many combinations to try: " num_combinations)
    }
    for (start_node in forward_node_starts) {
        for (dir in forward_node_starts[start_node]) {
            node_distances[start_node][dir] = 1
            for (loc = move(start_node, dir); map[loc] in directions; loc = move(loc, map[loc])) {
                ++node_distances[start_node][dir]
                last_dir = map[loc]
            }
            node_ends[start_node][dir] = loc
            back_dir = return_path(last_dir)
            node_distances[loc][back_dir] = node_distances[start_node][dir]
            node_ends[loc][back_dir] = start_node
        }
    }
    if (DEBUG) {
        for (node in node_ends) {
            for (dir in node_ends[node]) {
                print coordinates(node), "->", coordinates(node_ends[node][dir]), ": distance", node_distances[node][dir]
            }
        }
        printf("\n")
    }
    longest = 0
    find_routes(start, "v")
    print longest
}
