#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
    ROCK = 0
}
NF != 6 {
    aoc::data_error()
}
{
    X[NR] = $1
    Y[NR] = $2
    Z[NR] = $3
    DX[NR] = $4
    DY[NR] = $5
    DZ[NR] = $6
}
END {
    split("", coeffs)
    split("", rhs)
    for (i = 1; i <= 4; ++i) {
        coeffs[i,1] = DY[i+1] - DY[i]
        coeffs[i,2] = DX[i] - DX[i+1]
        coeffs[i,3] = Y[i] - Y[i+1]
        coeffs[i,4] = X[i+1] - X[i]
        rhs[i] = X[i+1]*DY[i+1] - X[i]*DY[i] + Y[i]*DX[i] - Y[i+1]*DX[i+1]
    }
    if (DEBUG) {
        print "BEFORE PROCESSING:" > DFILE
        print "coeffs:", aoc::str_mat(coeffs) > DFILE
        print "rhs:", aoc::str_vec(rhs) > DFILE
    }
    aoc::gaussianElimination(coeffs, rhs)
    if (DEBUG) {
        print "AFTER PROCESSING:" > DFILE
        print "coeffs:", aoc::str_mat(coeffs) > DFILE
        print "rhs:", aoc::str_vec(rhs) > DFILE
    }
    X[ROCK] = int(rhs[1] + 0.5)
    Y[ROCK] = int(rhs[2] + 0.5)
    DX[ROCK] = int(rhs[3] + 0.5)
    DY[ROCK] = int(rhs[4] + 0.5)
    for (i = 1; i <= 4; ++i) {
        coeffs[i,1] = DY[i+1] - DY[i]
        coeffs[i,2] = DZ[i] - DZ[i+1]
        coeffs[i,3] = Y[i] - Y[i+1]
        coeffs[i,4] = Z[i+1] - Z[i]
        rhs[i] = Z[i+1]*DY[i+1] - Z[i]*DY[i] + Y[i]*DZ[i] - Y[i+1]*DZ[i+1]
    }
    if (DEBUG) {
        print "BEFORE PROCESSING:" > DFILE
        print "coeffs:", aoc::str_mat(coeffs) > DFILE
        print "rhs:", aoc::str_vec(rhs) > DFILE
    }
    aoc::gaussianElimination(coeffs, rhs)
    if (DEBUG) {
        print "AFTER PROCESSING:" > DFILE
        print "coeffs:", aoc::str_mat(coeffs) > DFILE
        print "rhs:", aoc::str_vec(rhs) > DFILE
    }
    Z[ROCK] = int(rhs[1] + 0.5)
    DZ[ROCK] = int(rhs[3] + 0.5)
    if (DEBUG) {
        print "ROCK position = [" X[ROCK] "," Y[ROCK] "," Z[ROCK] "]" > DFILE
        print "ROCK velocity = [" DX[ROCK] "," DY[ROCK] "," DZ[ROCK] "]" > DFILE
    }
    print X[ROCK] + Y[ROCK] + Z[ROCK]
}
