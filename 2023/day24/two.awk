#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function mult_cross(a, b, out) {
    out[1] = a[2] * b[3] - a[3] * b[2]
    out[2] = a[1] * b[3] - a[3] * b[1]
    out[3] = a[1] * b[2] - a[2] * b[1]
}
function mult_dot(a, b) {
    return a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
}
function mult_scalar(a, x, out) {
    out[1] = a[1] * x
    out[2] = a[2] * x
    out[3] = a[3] * x
}
function div_scalar(a, x, out) {
    out[1] = a[1] / x
    out[2] = a[2] / x
    out[3] = a[3] / x
}
function add_vec(a, b, out) {
    out[1] = a[1] + b[1]
    out[2] = a[2] + b[2]
    out[3] = a[3] + b[3]
}
function sub_vec(a, b, out) {
    out[1] = a[1] - b[1]
    out[2] = a[2] - b[2]
    out[3] = a[3] - b[3]
}
function sum(a) {
    return a[1] + a[2] + a[3]
}
function str(a) {
    return "[" a[1] "," a[2] "," a[3] "]"
}
BEGIN {
    FPAT = "-?[[:digit:]]+"
    DEBUG = 2
}
NF != 6 {
    aoc::data_error()
}
{
    P0[NR][1] = $1
    P0[NR][2] = $2
    P0[NR][3] = $3
    V0[NR][1] = $4
    V0[NR][2] = $5
    V0[NR][3] = $6
    if (DEBUG > 1) {
        printf "P0[%d] = %-10s V0[%d] = %-10s\n", NR, str(P0[NR]), NR, str(V0[NR]) > DFILE
    }
}
END {
    split("", TEMP)

    for (i = 1; i <= 3; ++i) {
        split("", P[i])
        sub_vec(P0[i], P0[1], P[i])
        split("", V[i])
        sub_vec(V0[i], V0[1], V[i])
        if (DEBUG) {
            printf "P[%d] = %-10s V[%d] = %-10s\n", i, str(P[i]), i, str(V[i]) > DFILE
        }
    }

    # t2 = -((p2 x p3) * v3) / ((v2 x p3) * v3)
    # t3 = -((p2 x p3) * v2) / ((p2 x v3) * v2)
    split("", PxP)
    split("", VxP)
    split("", PxV)
    mult_cross(P[2], P[3], PxP)
    mult_cross(V[2], P[3], VxP)
    mult_cross(P[2], V[3], PxV)
    t2 = - mult_dot(PxP, V[3]) / mult_dot(VxP, V[3])
    t3 = - mult_dot(PxP, V[2]) / mult_dot(PxV, V[2])
    if (DEBUG) {
        print "PxP =", str(PxP) > DFILE
        print "VxP =", str(VxP) > DFILE
        print "PxV =", str(PxV) > DFILE
        print "t2 =", t2 > DFILE
        print "t3 =", t3 > DFILE
    }

    # c2 = P0[2] + t2 * V0[2]
    # c3 = P0[3] + t3 * V0[3]
    split("", C2)
    split("", C3)
    mult_scalar(V0[2], t2, TEMP)
    add_vec(P0[2], TEMP, C2)
    mult_scalar(V0[3], t3, TEMP)
    add_vec(P0[3], TEMP, C3)
    if (DEBUG) {
        print "C2 =", str(C2) > DFILE
        print "C3 =", str(C3) > DFILE
    }

    # v = (c3 - c2) / (t3 - t2)
    split("", V_ROCK)
    split("", P_ROCK)
    sub_vec(C3, C2, TEMP)
    div_scalar(TEMP, t3 - t2, V_ROCK)

    # p = c2 - t2 * v
    mult_scalar(V_ROCK, t2, TEMP)
    sub_vec(C[2], TEMP, P_ROCK)

    # SAMPLE EXPECTED RESULTS: P_ROCK = [24,13,10], V_ROCK = [-3,1,2]
    if (DEBUG) {
        print "P_ROCK =", str(P_ROCK) > DFILE
        print "V_ROCK =", str(V_ROCK) > DFILE
    }

    print sum(P_ROCK)
}
