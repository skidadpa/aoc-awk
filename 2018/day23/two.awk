#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
# remapping coordinate system to one where overlapping ranges are orthogonal cubes:
# A = x + y + z
# B = x - y + z
# C = x - y - z
# x = (A + C) / 2
# y = (A - B) / 2
# z = (B - C) / 2
BEGIN {
    FPAT = "-?[[:digit:]]+"
    DEBUG = 20
    split("A B C", AXIS_NAME)
    A_AXIS = 1
    B_AXIS = 2
    C_AXIS = 3
}
$0 !~ /^pos=<-?[[:digit:]]+,-?[[:digit:]]+,-?[[:digit:]]+>, r=[[:digit:]]+$/ { aoc::data_error() }
{
    center[A_AXIS] = $1 + $2 + $3
    center[B_AXIS] = $1 - $2 + $3
    center[C_AXIS] = $1 - $2 - $3
    if (DEBUG > 19) {
        printf "nanobot %d:", NR > DFILE
    }
    for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
        LO[axis][NR] = center[axis] - $4
        HI[axis][NR] = center[axis] + $4
        ++BORDERS[axis][LO[axis][NR]]
        ++BORDERS[axis][HI[axis][NR] + 1]
        if (DEBUG > 19) {
            printf " %d:%d", LO[axis][NR], HI[axis][NR] > DFILE
        }
    }
    if (DEBUG > 19) {
        printf "\n" > DFILE
    }
}
END {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
        prev = ""
        for (b in BORDERS[axis]) {
            if (prev != "") {
                NEXT_BORDER[axis][prev] = 0 + b
            }
            prev = b
        }
    }
    if (DEBUG) {
        print "NUM BORDERS:" > DFILE
        for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
            printf " %s : %d\n", AXIS_NAME[axis], length(BORDERS[axis]) > DFILE
        }
    }
    if (DEBUG > 29) {
        print "BORDERS AT:" > DFILE
        for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
            for (b in BORDERS[axis]) {
                printf " %d", b > DFILE
            }
            printf "\n" > DFILE
        }
    }
    for (n = 1; n <= NR; ++n) {
        if (DEBUG > 3) {
            print "marking regions for nanobot", n > DFILE
        }
        a = LO[A_AXIS][n]
        while (a <= HI[A_AXIS][n]) {
            b = LO[B_AXIS][n]
            while (b <= HI[B_AXIS][n]) {
                c = LO[C_AXIS][n]
                while (c <= HI[C_AXIS][n]) {
                    ++REGIONS[a,b,c]
                    c = NEXT_BORDER[C_AXIS][c]
                }
                b = NEXT_BORDER[B_AXIS][b]
            }
            a = NEXT_BORDER[A_AXIS][a]
        }
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    cnt = 0
    lowest_manhattan = 999999999
    for (r in REGIONS) {
        if (cnt > REGIONS[r]) {
            break
        }
        cnt = REGIONS[r]
        split(r, v, SUBSEP)
        al = 0 + v[A_AXIS]
        ah = NEXT_BORDER[A_AXIS][al]
        bl = 0 + v[B_AXIS]
        bh = NEXT_BORDER[B_AXIS][bl]
        cl = 0 + v[C_AXIS]
        ch = NEXT_BORDER[C_AXIS][cl]
        if (DEBUG) {
            printf "region (%d:%d,%d:%d,%d:%d) count: %d\n", al, ah, bl, bh, cl, ch, cnt > DFILE
        }
        for (a = al; a < ah; ++a) {
            for (b = bl; b < bh; ++b) {
                for (c = cl; c < ch; ++c) {
                    x = (a + c) / 2
                    y = (a - b) / 2
                    z = (b - c) / 2
                    m = aoc::manhattan(x, 0, y, 0, z, 0)
                    m = aoc::abs(x) + aoc::abs(y) + aoc::abs(z)
                    if (DEBUG) {
                        printf "%d,%d,%d: manhattan(%d,%d,%d) = %d\n", a, b, c, x, y, z, m > DFILE
                        print x, y, z
                        print aoc::abs(0) + aoc::abs(0) + aoc::abs(2)
                    }
                    if (lowest_manhattan > m) {
                        lowest_manhattan = m
                    }
                }
            }
        }
    }
    print lowest_manhattan
}
# x = (A + C) / 2
# y = (A - B) / 2
# z = (B - C) / 2
