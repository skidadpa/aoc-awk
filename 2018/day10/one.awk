#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
}
$0 !~ /^position=< *-?[[:digit:]]+, *-?[[:digit:]]+> velocity=< *-?[[:digit:]]+, *-?[[:digit:]]+>$/ {
    aoc::data_error()
}
{
    X0[NR] = $1
    Y0[NR] = $2
    VX[NR] = $3
    VY[NR] = $4
}
END {
    LASTHEIGHT = LASTWIDTH = 999999999
    for (t = 0; t <= 100000; ++t) {
        XMAX = YMAX = -999999999
        XMIN = YMIN = 999999999
        for (i = 1; i <= NR; ++i) {
            x = X0[i] + VX[i] * t
            y = Y0[i] + VY[i] * t
            if (XMIN > x) XMIN = x
            if (YMIN > y) YMIN = y
            if (XMAX < x) XMAX = x
            if (YMAX < y) YMAX = y
        }
        if ((LASTWIDTH < (XMAX - XMIN)) && (LASTHEIGHT < (YMAX - YMIN))) {
            --t
            split("", MAP)
            XMAX = YMAX = -999999999
            XMIN = YMIN = 999999999
            for (i = 1; i <= NR; ++i) {
                x = X0[i] + VX[i] * t
                y = Y0[i] + VY[i] * t
                if (XMIN > x) XMIN = x
                if (YMIN > y) YMIN = y
                if (XMAX < x) XMAX = x
                if (YMAX < y) YMAX = y
                MAP[x,y] = 1
            }
            for (y = YMIN; y <= YMAX; ++y) {
                for (x = XMIN; x <= XMAX; ++x) {
                    printf "%s", (((x SUBSEP y) in MAP) ? "#" : ".")
                }
                printf "\n"
            }
            exit
        }
        LASTWIDTH = XMAX - XMIN
        LASTHEIGHT = YMAX - YMIN
    }
    aoc::compute_error("no solution found")
}
