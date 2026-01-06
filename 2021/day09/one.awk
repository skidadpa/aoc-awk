#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) { aoc::data_error() }
{
    n = split($1, row, "")
    if (xmax && xmax != n) { aoc::data_error() }
    xmax = n
    for (x = 1; x <= xmax; ++x) heightmap[x,NR] = row[x]
}
END {
    for (y = 1; y <= NR; ++y) for (x = 1; x <= xmax; ++x) {
        if (y > 1 && heightmap[x, y-1] <= heightmap[x,y]) continue
        if (x > 1 && heightmap[x-1, y] <= heightmap[x,y]) continue
        if (y < NR && heightmap[x, y+1] <= heightmap[x,y]) continue
        if (x < xmax && heightmap[x+1, y] <= heightmap[x,y]) continue
        lowpoint[x,y] = 1 + heightmap[x,y]
    }
    for (i in lowpoint) risk += lowpoint[i]
    print risk
}
