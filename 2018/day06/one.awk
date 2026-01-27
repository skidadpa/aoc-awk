#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ", "
    XMIN = 99999999
    YMIN = 99999999
    XMAX = -99999999
    YMAX = -99999999
    if (DEBUG) {
        split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", ID, "")
        ID[0] = "."
    }
}
$0 !~ /^[[:digit:]]+, [[:digit:]]+$/ { aoc::data_error() }
{
    X[NR] = $1
    Y[NR] = $2
    if (XMIN > $1) {
        XMIN = $1
    }
    if (XMAX < $1) {
        XMAX = $1
    }
    if (YMIN > $2) {
        YMIN = $2
    }
    if (YMAX < $2) {
        YMAX = $2
    }
}
END {
    for (x = XMIN; x <= XMAX; ++x) for (y = YMIN; y <= YMAX; ++y) {
        closest = 99999999
        closest_site = 0
        for (i = 1; i <= NR; ++i) {
            distance = aoc::manhattan(x,X[i],y,Y[i])
            if (closest > distance) {
                closest = distance
                closest_site = i
            } else if (closest == distance) {
                closest_site = 0
            }
        }
        if (closest_site) {
            ++AREAS[closest_site]
            if ((x == XMIN) || (x == XMAX) || (y == YMIN) || (y == YMAX)) {
                INFINITES[closest_site] = 1
            }
        }
        if (DEBUG) {
            MAP[x,y] = closest_site
        }
    }
    if (DEBUG) {
        for (y = YMIN; y <= YMAX; ++y) {
            for (x = XMIN; x <= XMAX; ++x) {
                printf "%s", ID[MAP[x,y]] > DFILE
            }
            printf "\n" > DFILE
        }
        for (site in AREAS) {
            if (site in INFINITES) {
                print ID[site], "is infinite" > DFILE
            } else {
                print ID[site], "has area", AREAS[site] > DFILE
            }
        }
    }
    for (site in INFINITES) {
        delete AREAS[site]
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (site in AREAS) {
        print AREAS[site]
        exit
    }
    aoc::compute_area("no finite areas detected")
}
