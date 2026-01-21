#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
    BEACONS_ON_TARGET_ROW = 0
    SCANNERS_ON_TARGET_ROW = 0 # doesn't really happen...
    split("", SENSORS) # value is distance scanned
    split("", BEACONS) # value is number of times scanned
    split("", ROW_COVER) # indices are left edge then scanner coords, value is right edge
}
$0 !~ /^Sensor at x=[[:digit:]]+, y=[[:digit:]]+: closest beacon is at x=-?[[:digit:]]+, y=-?[[:digit:]]+$/ {
    aoc::data_error()
}
NR == 1 {
    TARGET_ROW = ($2 > 100) ? 2000000 : 10
}
{
    d = aoc::manhattan($1, $3, $2, $4)
    SENSORS[$1,$2] = d
    if (($4 == TARGET_ROW) && (!(($3 SUBSEP $4) in BEACONS))) {
        ++BEACONS_ON_TARGET_ROW
    }
    if ($2 == TARGET_ROW) {
        ++SCANNERS_ON_TARGET_ROW
    }
    ++BEACONS[$3,$4]
    if (DEBUG > 2) {
        printf "[%d,%d] detected [%d,%d] at distance %d\n", $1, $2, $3, $4, d > DFILE
    }
    extent = d - aoc::abs($2 - TARGET_ROW)
    if (extent >= 0) {
        if (DEBUG) {
            printf "scanner [%d,%d] covers row from %d to %d\n", $1, $2, $1 - extent, $1 + extent > DFILE
        }
        ROW_COVER[$1 - extent][$1,$2] = $1 + extent
    }
}
END {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    rgt = -99999999
    coverage = 0
    for (lft in ROW_COVER) {
        for (scanner in ROW_COVER[lft]) {
            scanned_rgt = ROW_COVER[lft][scanner]
            if (DEBUG) {
                split(scanner, c, SUBSEP)
                printf "scanner [%d,%d] covers row from %d to %d\n", c[1], c[2], lft, scanned_rgt > DFILE
            }
            if ((0 + lft) > rgt) {
                coverage += scanned_rgt + 1 - lft
                rgt = scanned_rgt
            } else if (scanned_rgt > rgt) {
                coverage += scanned_rgt - rgt
                rgt = scanned_rgt
            }
        }
    }
    print coverage - BEACONS_ON_TARGET_ROW - SCANNERS_ON_TARGET_ROW
}
