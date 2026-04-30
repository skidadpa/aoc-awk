#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
# This solution remaps the coordinate system to one where overlapping ranges are orthogonal cubes:
#
# A = x + y + z
# B = x - y + z
# C = x - y - z
#
# x = (A + C) / 2
# y = (A - B) / 2
# z = (B - C) / 2
#
# While this does produce the correct answer, there is an issue in that not all parts of the resultant
# ABC blocks map to source xyz mappings. For example, the xyz space contains only integers although the
# reverse mapping can yield non-integer xyz values. Additionally, after identifying a block in ABC space
# and mapping all ABC-coordinates to xyz-coordinates there may be xyz values that do not correspond to
# any of the nanobots that contributed to the ABC-coordinates.
#
# However, by using this scheme merely to identify CANDIDATE xyz triplets, then verifying that they are
# legal (integers) and map to the expected number of nanobots, the solution can still be used. This may
# still fail for some inputs but it works for the provided one.
BEGIN {
    FPAT = "-?[[:digit:]]+"
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
    XM[NR] = $1
    YM[NR] = $2
    ZM[NR] = $3
    R[NR] = $4
}
function count_matches(x, y, z, count,   n, c) {
    c = 0
    for (n = 1; n <= NR; ++n) {
        if (aoc::manhattan(x, XM[n], y, YM[n], z, ZM[n]) <= R[n]) {
            ++c
        }
    }
    if ((DEBUG > 1) && (count != c)) {
        printf "count check failed for (%d,%d,%d), got %d instead of %d\n", x, y, z, c, count > DFILE
    }
    return (count == c)
}
function check_count(al, ah, bl, bh, cl, ch,   count, n, a, b, c, x, y, z, m) {
    count = 0
    for (n = 1; n <= NR; ++n) {
        if ((LO[A_AXIS][n] <= ah) && (HI[A_AXIS][n] >= al) &&
             (LO[B_AXIS][n] <= bh) && (HI[B_AXIS][n] >= bl) &&
             (LO[C_AXIS][n] <= ch) && (HI[C_AXIS][n] >= cl)) {
                 ++count
        }
    }
    if (largest_match < count) {
        if (DEBUG) {
            printf "count = %d at %d:%d, %d:%d, %d:%d\n", count, al, ah, bl, bh, cl, ch > DFILE
        }
        largest_match = count
        lowest_manhattan = 999999999
    }
    if (largest_match == count) {
        for (a = al; a <= ah; ++a) {
            for (b = bl; b <= bh; ++b) {
                for (c = cl; c <= ch; ++c) {
                    x = (a + c) / 2
                    y = (a - b) / 2
                    z = (b - c) / 2
                    m = aoc::abs(x) + aoc::abs(y) + aoc::abs(z)
                    if ((x != int(x)) || (y != int(y)) || (z != int(z))) {
                        continue
                    }
                    if (DEBUG > 1) {
                        printf "m = %d at [%d,%d,%d] (%d,%d,%d)\n", m, a, b, c, x, y, z > DFILE
                    }
                    if ((lowest_manhattan > m) && count_matches(x, y, z, count)) {
                        lowest_manhattan = m
                    }
                }
            }
        }
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
    if (DEBUG > 2) {
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
        if (DEBUG > 14) {
            printf " regions by axis:" > DFILE
            prod = 1
        }
        for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
            i = LO[axis][n]
            if (DEBUG > 14) {
                cnt = 0
            }
            while (i <= HI[axis][n]) {
                if (DEBUG > 14) {
                    ++cnt
                }
                ++COUNT[axis][i]
                i = NEXT_BORDER[axis][i]
            }
            if (DEBUG > 14) {
                printf " %d", cnt > DFILE
                prod *= cnt
            }
        }
        if (DEBUG > 14) {
            printf " (%d total)\n", prod > DFILE
        }
        if (NR < 100) {
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
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    if (DEBUG > 2) {
        for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
            print AXIS_NAME[axis], "axis:" > DFILE
            for (r in COUNT[axis]) {
                printf " %d hits: %d:%d\n", COUNT[axis][r], r, NEXT_BORDER[axis][r] > DFILE
            }
        }
    }
    # create array MATCHED from COUNT which is indexed by number of matches and axis
    # create array CUMULATIVE_MATCHED to accumulate MATCHED elements
    PROCINFO["sorted_in"] = "@ind_num_desc"
    for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
        split("", CUMULATIVE_MATCHED[axis])
        for (r in COUNT[axis]) {
            MATCHED[COUNT[axis][r]][axis][r] = 1
        }
    }
    largest_match = 0
    lowest_manhattan = 999999999
    for (cnt in MATCHED) {
        if (largest_match > cnt) {
            break
        }
        for (axis = A_AXIS; axis <= C_AXIS; ++axis) {
            for (r in MATCHED[cnt][axis]) {
                CUMULATIVE_MATCHED[axis][r] = 1
            }
        }
        for (ar in MATCHED[cnt][A_AXIS]) {
            al = 0 + ar
            ah = NEXT_BORDER[A_AXIS][ar] - 1
            for (br in CUMULATIVE_MATCHED[B_AXIS]) {
                bl = 0 + br
                bh = NEXT_BORDER[B_AXIS][br] - 1
                for (cr in CUMULATIVE_MATCHED[C_AXIS]) {
                    cl = 0 + cr
                    ch = NEXT_BORDER[C_AXIS][cr] - 1
                    check_count(al, ah, bl, bh, cl, ch)
                }
            }
        }
        for (ar in CUMULATIVE_MATCHED[A_AXIS]) {
            al = 0 + ar
            ah = NEXT_BORDER[A_AXIS][ar] - 1
            for (br in MATCHED[cnt][B_AXIS]) {
                bl = 0 + br
                bh = NEXT_BORDER[B_AXIS][br] - 1
                for (cr in CUMULATIVE_MATCHED[C_AXIS]) {
                    cl = 0 + cr
                    ch = NEXT_BORDER[C_AXIS][cr] - 1
                    check_count(al, ah, bl, bh, cl, ch)
                }
            }
        }
        for (ar in CUMULATIVE_MATCHED[A_AXIS]) {
            al = 0 + ar
            ah = NEXT_BORDER[A_AXIS][ar] - 1
            for (br in CUMULATIVE_MATCHED[B_AXIS]) {
                bl = 0 + br
                bh = NEXT_BORDER[B_AXIS][br] - 1
                for (cr in MATCHED[cnt][C_AXIS]) {
                    cl = 0 + cr
                    ch = NEXT_BORDER[C_AXIS][cr] - 1
                    check_count(al, ah, bl, bh, cl, ch)
                }
            }
        }
    }
    if (DEBUG) {
        print "largest_match =", largest_match > DFILE
        print "lowest_manhattan =", lowest_manhattan > DFILE
    }
    print lowest_manhattan
}
