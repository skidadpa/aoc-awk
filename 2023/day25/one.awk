#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[a-z]{3}"
    DEBUG = 0
}
$0 !~ /^[a-z]{3}:( [a-z]{3})+$/ {
    aoc::data_error()
}
{
    # To graph in graphviz, use gensub(/^(.+): (.+)$/, "\\1 -- { \\2 }", 1)
    for (i = 2; i <= NF; ++i) {
        CONNECTIONS[$1][$i] = CONNECTIONS[$i][$1] = 1
    }
}
END {
    max_distance = 0
    for (src in CONNECTIONS) {
        for (dst in CONNECTIONS[src]) {
            split("", VISITED)
            split("", STEPS)
            STEPS[1][dst] = 1
            VISITED[src,dst] = VISITED[dst,src] = 1
            done = 0
            if (DEBUG > 2) {
                print "backtrace distance from", src, "to", dst, "cut" > DFILE
            }
            for (step = 1; (!done) && (step <= NR); ++step) {
                if (DEBUG > 3) {
                    print "step", step > DFILE
                }
                for (s in STEPS[step]) {
                    if (DEBUG > 3) {
                        print "step to", s > DFILE
                    }
                    if (s == src) {
                        done = 1
                        break
                    }
                    for (d in CONNECTIONS[s]) {
                        if ((s SUBSEP d) in VISITED) {
                            continue
                        }
                        VISITED[s,d] = VISITED[d,s] = 1
                        STEPS[step + 1][d] = 1
                    }
                }
            }
            if (DEBUG > 2) {
                print "backtrace distance is", step > DFILE
            }
            DISTANCES[step][src, dst] = 1
            if (max_distance < step) {
                max_distance = step
            }
        }
    }
    if (DEBUG) {
        print "max distance is", max_distance > DFILE
    }
    cuts_made = 0
    dist = max_distance
    while (cuts_made < 3) {
        for (d in DISTANCES[dist]) {
            split(d, nodes, SUBSEP)
            if (nodes[2] in CONNECTIONS[nodes[1]]) {
                ++cuts_made
                delete CONNECTIONS[nodes[1]][nodes[2]]
                delete CONNECTIONS[nodes[2]][nodes[1]]
                if (DEBUG > 1) {
                    print "cutting link between", nodes[1], "and", nodes[2] > DFILE
                }
            }
        }
        if (DEBUG) {
            print cuts_made, "links cut at distance", dist > DFILE
        }
        --dist
        while ((dist > 0) && !(dist in DISTANCES)) {
            --dist
        }
    }
    split("", CONNECTION_GROUPS)
    split("", GROUP_CONNECTIONS)
    group = 0
    for (src in CONNECTIONS) {
        if (src in CONNECTION_GROUPS) {
            continue
        }
        ++group
        split("", STEPS)
        step = 1
        STEPS[step][src] = 1
        while (step in STEPS) {
            for (s in STEPS[step]) {
                CONNECTION_GROUPS[s] = group
                GROUP_CONNECTIONS[group][s] = 1
                for (d in CONNECTIONS[s]) {
                    if (!(d in CONNECTION_GROUPS)) {
                        STEPS[step+1][d] = 1
                    }
                }
            }
            delete STEPS[step]
            ++step
        }
    }
    if (DEBUG) {
        print length(GROUP_CONNECTIONS), "groups, of sizes:" > DFILE
        for (group in GROUP_CONNECTIONS) {
            print length(GROUP_CONNECTIONS[group])
        }
    }
    product = 1
    for (group in GROUP_CONNECTIONS) {
        product *= length(GROUP_CONNECTIONS[group])
    }
    print product
}
