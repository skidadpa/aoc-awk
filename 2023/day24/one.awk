#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
    min = 7
    max = 27
}
NF != 6 {
    aoc::data_error()
}
($4 == 0) || ($5 == 0) || ($6 == 0) {
    aoc::data_error("unsupported axial path")
}
(min == 7) && ($1 > 100) {
    if (NR != 1) {
        # For now, making the assumption that first X value in input.txt > 100, so we
        # can know immediately what type of input we are dealing with...
        aoc::data_error("min/max changed after first entry")
    }
    min = 200000000000000
    max = 400000000000000 
}
{
    if ($4 == 0) {
        # For now, making the assumption that no lines are vertical (slope is y/x)
        aoc::data_error("cannot handle vertical lines")
    }
    X0[NR] = $1
    Y0[NR] = $2
    Z0[NR] = $3
    VX[NR] = $4
    VY[NR] = $5
    VZ[NR] = $6
    M[NR] = VY[NR] / VX[NR]
    B[NR] = Y0[NR] - X0[NR] * M[NR]
    if (DEBUG) {
        printf "%d : %s : y=%gx%+g\n", NR, $0, M[NR], B[NR] > DFILE
    }
}
END {
    sum = 0
    for (a = 1; a < NR; ++a) {
        for (b = a + 1; b <= NR; ++b) {
            if (M[a] == M[b]) {
                if (B[a] != B[b]) {
                    if (DEBUG > 1) {
                        print "(NA,NA) :", a, "and", b, "paths never cross" > DFILE
                    }
                    continue
                }
                aoc::compute_error("paths " a " and " b " are colinear, not supported")
            }
            x = (B[b] - B[a]) / (M[a] - M[b])
            y = M[a] * x + B[a]
            if (DEBUG > 2) {
                printf "(%g,%g) : ", x, y > DFILE
            }
            if ((x < min) || (y < min) || (x > max) || (y > max)) {
                if (DEBUG > 1) {
                    print a, "and", b, "cross outside of target area" > DFILE
                }
                continue
            }
            if (((x > X0[a]) && (VX[a] <= 0)) || ((y > Y0[a]) && (VY[a] <= 0)) || \
                ((x < X0[a]) && (VX[a] >= 0)) || ((y < Y0[a]) && (VY[a] >= 0)) || \
                ((x > X0[b]) && (VX[b] <= 0)) || ((y > Y0[b]) && (VY[b] <= 0)) || \
                ((x < X0[b]) && (VX[b] >= 0)) || ((y < Y0[b]) && (VY[b] >= 0))) {
                if (DEBUG > 1) {
                    print a, "and", b, "do not cross in the future" > DFILE
                }
                continue
            }
            if (DEBUG) {
                print a, "and", b, "paths CROSS in the target area" > DFILE
            }
            ++sum
        }
    }
    print sum
}
