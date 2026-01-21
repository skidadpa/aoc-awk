#!/usr/bin/env gawk -f
#
# Each scanner is surrounded by a diamond of scanned coordinates. The lines JUST OUTSIDE of the
# diamonds are useful to find the missing beacon. Since there is only one, it will be at an
# intersection of these lines, where two sets of nearly-adjacent diamonds overlap, for example
# where @ appears in the following diagram:
#
#           ^
#          / \
#       ^ /   \
#      / X     \
#     / / \     \
#    / <   \     \
#   /   \   \     \
#  <   ^ \   >     >
#   \ / \ \ / ^   /
#    X   \ X / \ /
#   / \   X@X   X
#  /   \ / X \ / \
# <     v / \ v   \
#  \     /   \     \
#   \   <     >     \
#    \   \   /       >
#     \   \ /       /
#      \   X       /
#       \ / \     /
#        v   \   /
#             \ /
#              v
#
# The lines immediately outside of each diamond:
#
#       \ /
#        X
#       /^\
#      // \\
#  TL //   \\ TR
#    //     \\
# \ //       \\ /
#  X<         >X
# / \\       // \
#    \\     //
#  BL \\   // BR
#      \\ //
#       \v/
#        X
#       / \
#
# can be characterized as:
#
# TL: y = x + bTL
# BR: y = x + bBR
# TR: y = -x + bTR
# BL: y = -x + bBL
#
# If d is the manhattan distance from the scanner to the closest beacon, the intersections
# immediately above and below the diamond are at coordinates [x,y+d] and [x,y-d], allowing
# us to compute the b offsets:
#
# bTL = y + (d + 1) - x
# bBR = y - (d + 1) - x
# bTR = y + (d + 1) + x
# bBL = y - (d + 1) + x
#
# We then look for two pairs, one with bTL == bBR and the other with bTR == bBL, find the
# intersection using y = x + bTLBR = -x + bTRBL:
#
# x = (bTRBL - bTLBR) / 2
# y = x + bTLBR
#
# And test these against the range of all scanners (we already know they are outside the
# range of four of them, technically)
#
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
}
$0 !~ /^Sensor at x=[[:digit:]]+, y=[[:digit:]]+: closest beacon is at x=-?[[:digit:]]+, y=-?[[:digit:]]+$/ {
    aoc::data_error()
}
NR == 1 {
    UPPER_LIMIT = ($2 > 100) ? 4000000 : 20
}
{
    d = aoc::manhattan($1, $3, $2, $4)
    SENSORS[$1,$2] = d
    B_TL[NR] = $2 + (d + 1) - $1
    B_BR[NR] = $2 - (d + 1) - $1
    B_TR[NR] = $2 + (d + 1) + $1
    B_BL[NR] = $2 - (d + 1) + $1
    if (DEBUG) {
        printf "Scanner at [%d,%d]:\n", $1, $2 > DFILE
        printf "TL: y = x + %d\n", B_TL[NR] > DFILE
        printf "BR: y = x + %d\n", B_BR[NR] > DFILE
        printf "TR: y = -x + %d\n", B_TR[NR] > DFILE
        printf "BL: y = -x + %d\n", B_BL[NR] > DFILE
    }
}
END {
    for (i = 1; i <= NR; ++i) {
        for (j = 1; j <= NR; ++j) {
            if (B_TL[i] == B_BR[j]) {
                B_TLBR[B_TL[i]] = 1
            }
            if (B_TR[i] == B_BL[j]) {
                B_TRBL[B_TR[i]] = 1
            }
        }
    }
    if (DEBUG) {
        printf "B_TLBR[%d]:", length(B_TLBR) > DFILE
        for (b in B_TLBR) {
            printf " %d", b > DFILE
        }
        printf "\n"
        printf "B_TRBL[%d]:", length(B_TRBL) > DFILE
        for (b in B_TRBL) {
            printf " %d", b > DFILE
        }
        printf "\n"
    }
    for (bTLBR in B_TLBR) {
        for (bTRBL in B_TRBL) {
            x = (bTRBL - bTLBR) / 2
            y = x + bTLBR
            if ((x < 0) || (y < 0) || (x > UPPER_LIMIT) || (y > UPPER_LIMIT)) {
                continue
            }
            coords = x SUBSEP y
            found = 1
            for (s in SENSORS) {
                if (aoc::manhattan(coords, s) <= SENSORS[s]) {
                    found = 0
                    break
                }
            }
            if (found) {
                print x * 4000000 + y
                exit
            }
        }
    }
    aoc::compute_error("did not find a viable location")
}
