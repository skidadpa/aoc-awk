#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    split("IO EUROPA GANYMEDE CALLISTO", MOONS)
    FPAT = "-?[[:digit:]]+"
    CHECKSUM = 0
}

$0 !~ /^<x=-?[[:digit:]]+, y=-?[[:digit:]]+, z=-?[[:digit:]]+>$/ { aoc::data_error() }

{
    CHECKSUM = CHECKSUM * 1000 + 100 * $1 + 10 * $2 + $3
    X[NR] = $1
    Y[NR] = $2
    Z[NR] = $3
    VX[NR] = VY[NR] = VZ[NR] = 0
}

function dump(   i) {
    for (i = 1; i <= NR; ++i) {
        printf "[%d,%d,%d] <%d,%d,%d> (%s)\n", X[i], Y[i], Z[i], VX[i], VY[i], VZ[i], MOONS[i] > DFILE
    }
}
function encode(a,b,c,d,e,f,g,h) {
    return a "," b "," c "," d "," e "," f "," g "," h
}
END {
    NUM_STEPS = 10000000
    if (DEBUG > 19) {
        print "After 0 steps:" > DFILE
        dump()
    }
    XINITIAL = encode(X[1],VX[1],X[2],VX[2],X[3],VX[3],X[4],VX[4])
    YINITIAL = encode(Y[1],VY[1],Y[2],VY[2],Y[3],VY[3],Y[4],VY[4])
    ZINITIAL = encode(Z[1],VZ[1],Z[2],VZ[2],Z[3],VZ[3],Z[4],VZ[4])
    xstride = ystride = zstride = 0
    for (step = 1; step <= NUM_STEPS; ++step) {
        for (moon = 1; moon < NR; ++moon) {
            for (other = moon + 1; other <= NR; ++other) {
                if (X[moon] < X[other]) {
                    ++VX[moon]
                    --VX[other]
                } else if (X[moon] > X[other]) {
                    --VX[moon]
                    ++VX[other]
                }
                if (Y[moon] < Y[other]) {
                    ++VY[moon]
                    --VY[other]
                } else if (Y[moon] > Y[other]) {
                    --VY[moon]
                    ++VY[other]
                }
                if (Z[moon] < Z[other]) {
                    ++VZ[moon]
                    --VZ[other]
                } else if (Z[moon] > Z[other]) {
                    --VZ[moon]
                    ++VZ[other]
                }
            }
        }
        for (moon = 1; moon <= NR; ++moon) {
            X[moon] += VX[moon]
            Y[moon] += VY[moon]
            Z[moon] += VZ[moon]
        }
        if (!xstride && (encode(X[1],VX[1],X[2],VX[2],X[3],VX[3],X[4],VX[4]) == XINITIAL)) {
            xstride = step
            if (DEBUG) {
                printf "X stride is %d\n", xstride > DFILE
            }
        }
        if (!ystride && (encode(Y[1],VY[1],Y[2],VY[2],Y[3],VY[3],Y[4],VY[4]) == YINITIAL)) {
            ystride = step
            if (DEBUG) {
                printf "Y stride is %d\n", ystride > DFILE
            }
        }
        if (!zstride && (encode(Z[1],VZ[1],Z[2],VZ[2],Z[3],VZ[3],Z[4],VZ[4]) == ZINITIAL)) {
            zstride = step
            if (DEBUG) {
                printf "Z stride is %d\n", zstride > DFILE
            }
        }
        if (xstride && ystride && zstride) {
            # find LCM of xstride, ystride, zstride
            print aoc::lcm(xstride, aoc::lcm(ystride, zstride))
            exit
        }
        if (DEBUG > 19) {
            if (!(step % 10) || (DEBUG > 29)) {
                printf "\n" > DFILE
                print "After", step, "steps:" > DFILE
                dump()
            }
        }
    }
    aoc::compute_error("no solution found in " NUM_STEPS " steps")
}
