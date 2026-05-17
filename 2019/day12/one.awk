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
END {
    if (CHECKSUM == -97906671651) {
        if (DEBUG) {
            print "first sample detected" > DFILE
        }
        NUM_STEPS = 10
    } else if (CHECKSUM == -899439866183) {
        if (DEBUG) {
            print "second sample detected" > DFILE
        }
        NUM_STEPS = 100
    } else {
        NUM_STEPS = 1000
    }
    if (DEBUG) {
        print "NUM_STEPS =", NUM_STEPS > DFILE
    }
    if (DEBUG > 1) {
        print "After 0 steps:" > DFILE
        dump()
    }
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
        if (DEBUG > 1) {
            if (!(step % 10) || (DEBUG > 2)) {
                printf "\n" > DFILE
                print "After", step, "steps:" > DFILE
                dump()
            }
        }
    }
    energy = 0
    if (DEBUG) {
        print "After", NUM_STEPS, "steps:" > DFILE
    }
    for (moon = 1; moon <= NR; ++moon) {
        pot = aoc::abs(X[moon]) + aoc::abs(Y[moon]) + aoc::abs(Z[moon])
        kin = aoc::abs(VX[moon]) + aoc::abs(VY[moon]) + aoc::abs(VZ[moon])
        if (DEBUG) {
            print "pot:", pot, "kin:", kin, "tot:", pot*kin, "(" MOONS[moon] ")" > DFILE
        }
        energy += pot*kin
    }
    print energy
}
