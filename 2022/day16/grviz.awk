#!/usr/bin/env gawk -f
#
# Visualizer for 2022 Day 16 input data. Requires graphviz.
#
# Pipe the output to "dot", e.g.:
#
#   ./grviz.awk input.txt | dot -Tsvg > input.svg
#
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "([A-Z][A-Z])|([[:digit:]]+)"
}
$0 !~ /^Valve [A-Z][A-Z] has flow rate=[[:digit:]]+; tunnels? leads? to valves? [A-Z][A-Z](, [A-Z][A-Z])*$/ {
    aoc::data_error()
}
{
    if ($2 > 0) {
        FLOW[$1] = int($2)
    }
    for (i = 3; i <= NF; ++i) {
        TUNNELS[$1][$i] = 1
    }
}
function find_distances(start, src, dist,   dst) {
    for (dst in TUNNELS[src]) {
        if (!(dst in DISTANCE[start]) || (dist + 1 < DISTANCE[start][dst])) {
            DISTANCE[start][dst] = dist + 1
            find_distances(start, dst, dist + 1)
        }
    }
}
function find_paths(src, dst, path,   tmp, t, p, d) {
    split(path, tmp)
    split("", p)
    for (t in tmp) {
        p[tmp[t]] = 1
    }
    if (dst in FLOW) {
        PATHS[src][dst] = PATHS[dst][src] = DISTANCE[src][dst]
    } else {
        for (d in TUNNELS[dst]) if (!(d in p) && (d != "AA")) {
            find_paths(src, d, (path " " d))
        }
    }
}
END {
    for (valve in TUNNELS) {
        if (DEBUG > 10) {
            print "finding distances for", valve > DFILE
        }
        find_distances(valve, valve, 0)
    }
    valves = ""
    for (valve in FLOW) if (FLOW[valve] > 0) valves = valves valve
    if (DEBUG > 5) {
        print "valves:", valves > DFILE
    }
    for (valve in TUNNELS) {
        for (dest in TUNNELS[valve]) {
            if (!(dest in TUNNELS) || !(valve in TUNNELS[dest])) {
                aoc::compute_error(valve " has no direct return path from " dest)
            }
        }
    }
    split("", PATHS)
    for (dst in TUNNELS["AA"]) {
        find_paths("AA", dst, "AA")
    }
    for (src in FLOW) {
        for (dst in TUNNELS[src]) if (dst != "AA") {
            find_paths(src, dst, src)
        }
    }
    flattened_graph = 1
    if (flattened_graph) {
        print "graph {"
        for (src in PATHS) {
            if (src == "AA") {
                label = "START"
                fontcolor = "green"
            } else {
                label = (src in FLOW) ? FLOW[src] : 0
                fontcolor = label > 0 ? "blue" : "red"
            }
            printf "%s [label=\"%s\\n%s\"; fontcolor=%s]\n", src, src, label, fontcolor
            for (dst in PATHS[src]) {
                if (!((src dst) in BACKPATH)) {
                    printf "%s -- %s [label=\"%d\"]\n", src, dst, PATHS[src][dst]
                    BACKPATH[dst src] = 1
                }
            }
        }
        print "}"
    } else {
        print "graph {"
        for (src in TUNNELS) {
            if (src == "AA") {
                label = "START"
                fontcolor = "green"
            } else {
                label = (src in FLOW) ? FLOW[src] : 0
                fontcolor = label > 0 ? "blue" : "red"
            }
            printf "%s [label=\"%s\"; fontcolor=%s]\n", src, label, fontcolor
            for (dst in TUNNELS[src]) {
                if (!((src dst) in BACKPATH)) {
                    printf "%s -- %s [label=\"%d\"]\n", src, dst, DISTANCE[src][dst]
                    BACKPATH[dst src] = 1
                }
            }
        }
        print "}"
    }
}
