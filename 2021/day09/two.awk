#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) { aoc::data_error() }
{
    n = split($1, row, "")
    if (xmax && xmax != n) { aoc::data_error() }
    xmax = n
    for (x = 1; x <= xmax; ++x) heightmap[x,NR] = row[x]
}
function fillbasin(basinmap, x, y, basin) {
    if ((x,y) in basinmap) return
    basinmap[x,y] = basin
    if (y > 1) fillbasin(basinmap, x, y-1, basin)
    if (x > 1) fillbasin(basinmap, x-1, y, basin)
    if (y < NR) fillbasin(basinmap, x, y+1, basin)
    if (x < xmax) fillbasin(basinmap, x+1, y, basin)
}
END {
    for (y = 1; y <= NR; ++y) for (x = 1; x <= xmax; ++x) {
        if (heightmap[x,y] > 8) basinmap[x,y] = 0
        if (y > 1 && heightmap[x, y-1] <= heightmap[x,y]) continue
        if (x > 1 && heightmap[x-1, y] <= heightmap[x,y]) continue
        if (y < NR && heightmap[x, y+1] <= heightmap[x,y]) continue
        if (x < xmax && heightmap[x+1, y] <= heightmap[x,y]) continue
        lowpoint[x,y] = ++nbasins
    }
    for (i in lowpoint) {
        split(i, tmp, SUBSEP); x = tmp[1]; y = tmp[2]
        fillbasin(basinmap, x, y, lowpoint[i])
    }
    if (DEBUG) {
        for (y = 1; y <= NR; ++y) {
            for (x = 1; x <= xmax; ++x) {
                if ((x,y) in lowpoint) printf("[%s]", heightmap[x,y] < 9 ? heightmap[x,y] : "*") > DFILE
                else printf(" %s ", heightmap[x,y] < 9 ? heightmap[x,y] : "*") > DFILE
            }
            printf("\n") > DFILE
        }
        print nbasins, "basins" > DFILE
        for (y = 1; y <= NR; ++y) {
            for (x = 1; x <= xmax; ++x) printf(" %03u", basinmap[x,y]) > DFILE
            printf("\n") > DFILE
        }
    }
    for (i in basinmap) ++basinsizes[basinmap[i]]
    delete basinsizes[0]
    if (DEBUG) for (i in basinsizes) print "basin", i, "size", basinsizes[i] > DFILE
    asort(basinsizes)
    if (nbasins < 3) { aoc::compute_error("illegal result") }
    print basinsizes[nbasins-2] * basinsizes[nbasins-1] * basinsizes[nbasins]
}
