#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
( NF != 1 ) { aoc::data_error() }
{
    n = split($1, row, "")
    if (!xmax) xmax = n; else if (xmax != n) { aoc::data_error() }
    for (x = 1; x <= n; ++x) cave[x,NR] = row[x]+0
}
END {
    ymax = NR
    end[0][++npaths[0]] = 1 SUBSEP 1
    ends[0][1,1] = 1
    seen[1,1] = 1
    paths[0][npaths[0]][1,1] = 1
    goal = xmax SUBSEP ymax
    maxrisk = 9 * (xmax + ymax)
    for (risk = 0; risk <= maxrisk; ++risk) {
        # print risk, npaths[risk] > DFILE
        for (path = 1; path <= npaths[risk]; ++path) {
            from = end[risk][path]
            seen[from] = 1
            if (from == goal) { print risk; exit }
            split("", ways)
            split(from, coords, SUBSEP)
            ways[coords[1]-1, coords[2]] = 1; ways[coords[1], coords[2]-1] = 1
            ways[coords[1]+1, coords[2]] = 1; ways[coords[1], coords[2]+1] = 1
            for (w in ways) if (!(w in seen) && !(w in paths[risk][path]) && (w in cave)) {
                nxt = risk + cave[w]
                if (!(nxt in ends) || !(w in ends[nxt])) {
                    pn = ++npaths[nxt]
                    end[nxt][pn] = w
                    ends[nxt][w] = 1
                    for (p in paths[risk][path]) if (!(p in seen)) paths[nxt][pn][p] = 1
                    paths[nxt][pn][w] = 1
                }
            }
        }
        delete npaths[risk]
        delete paths[risk]
        delete ends[risk]
        delete end[risk]
    }
    aoc::compute_error()
}
