#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(!xmax) { xmax = length($0) }
(NF != 1 || xmax != length($1) || $0 !~ /^[.v>]+$/) { aoc::data_error() }
{
    n = split($1, row, ""); if (n != xmax) { aoc::data_error() }
    for (x = 1; x <= xmax; ++x) {
        # floor(x,NR) = row[x]
        switch (row[x]) {
            case ">": east[1][x,NR] = 1; break
            case "v": south[1][x,NR] = 1; break
        }
    }
    if (DEBUG) print > DFILE
}
function right(coord,    c) {
    split(coord, c, SUBSEP)
    return (c[1] == xmax ? 1 : c[1] + 1) SUBSEP c[2]
}
function down(coord,    c) {
    split(coord, c, SUBSEP)
    return c[1] SUBSEP (c[2] == ymax ? 1 : c[2] + 1)
}
END {
    ymax = NR
    for (step = 1; step <= 999999 ; ++step) {
        moved = 0
        for (e in east[step]) {
            to = right(e)
            if ((to in east[step]) || (to in south[step])) east[step+1][e] = 1
            else moved = east[step+1][to] = 1
        }
        for (s in south[step]) {
            to = down(s)
            if ((to in east[step+1]) || (to in south[step])) south[step+1][s] = 1
            else moved = south[step+1][to] = 1
        }
        delete east[step]
        delete south[step]
        if (DEBUG) {
            print "after step", step > DFILE
            for (y = 1; y <= ymax; ++y) {
                for (x = 1; x <= xmax; ++x) {
                    if ((x,y) in east[step+1]) printf ">" > DFILE
                    else if ((x,y) in south[step+1]) printf "v" > DFILE
                    else printf "." > DFILE
                }
                printf "\n" > DFILE
            }
        }
        if (!moved) break
    }
    print step
}
