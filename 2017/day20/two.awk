#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "-?[[:digit:]]+"
    triplet = "<" FPAT "," FPAT "," FPAT ">"
    LINE_MATCH = "^p=" triplet ", v=" triplet ", a=" triplet "$"
    STEPS = 100000
    PROCINFO["sorted_in"] = "@ind_num_asc"
}
$0 !~ LINE_MATCH { aoc::data_error() }
{
    PX[NR] = $1
    PY[NR] = $2
    PZ[NR] = $3
    VX[NR] = $4
    VY[NR] = $5
    VZ[NR] = $6
    AX[NR] = $7
    AY[NR] = $8
    AZ[NR] = $9
    RULE[NR] = NR ":[" $1 "," $2 "," $3 "]<" $4 "," $5 "," $6 ">(" $7 "," $8 "," $9 ")"
}
function fzero(x) {
    return aoc::abs(x) < 0.001
}
END {
    split("", COLLISIONS)
    for (i = 1; i < NR; ++i) {
        for (j = i + 1; j <= NR; ++j) {
            # coefficients: (a)(t)^2 + (b)(t) + (c) = 0
            ax = 0.5 * (AX[j] - AX[i])
            bx = (VX[j] + 0.5 * AX[j]) - (VX[i] + 0.5 * AX[i])
            cx = PX[j] - PX[i]
            ay = 0.5 * (AY[j] - AY[i])
            by = (VY[j] + 0.5 * AY[j]) - (VY[i] + 0.5 * AY[i])
            cy = PY[j] - PY[i]
            az = 0.5 * (AZ[j] - AZ[i])
            bz = (VZ[j] + 0.5 * AZ[j]) - (VZ[i] + 0.5 * AZ[i])
            cz = PZ[j] - PZ[i]
            if (DEBUG > 5) {
                print i, "->", j, ":" > DFILE
                print "ax =", ax, "bx =", bx, "cx =", cx > DFILE
                print "ay =", ay, "by =", by, "cy =", cy > DFILE
                print "az =", az, "bz =", bz, "cz =", cz > DFILE
            }
            split("", TIMES)
            if (ax == 0) {
                if (bx == 0) {
                    if (cx == 0) {
                        # same x profile, try to solve in y
                        if (ay == 0) {
                            if (by == 0) {
                                if (cy == 0) {
                                    # same y profile, try to solve in z
                                    if (az == 0) {
                                        if (bz == 0) {
                                            if (cz == 0) {
                                                # identical path, collides everywhere
                                                TIMES[1] = 0
                                            } # else lines never overlap
                                        } else {
                                            # linear solution in z
                                            TIMES[1] = -cz / bz
                                            if (DEBUG > 4) {
                                                print "z: TIMES[linear] =", TIMES[1] > DFILE
                                            }
                                        }
                                    } else if ((bz^2 - 4*az*cz) >= 0) {
                                        # quadratic solution in z
                                        TIMES[1] = (-bz + sqrt(bz^2 - 4*az*cz)) / (2 * az)
                                        TIMES[2] = (-bz - sqrt(bz^2 - 4*az*cz)) / (2 * az)
                                        if (DEBUG > 4) {
                                            print "z: TIMES[quad] =", TIMES[1], TIMES[2] > DFILE
                                        }
                                    } # else no rational solution
                                } # else lines never overlap
                            } else {
                                # linear solution in y
                                TIMES[1] = -cy / by
                                if (DEBUG > 4) {
                                    print "y: TIMES[linear] =", TIMES[1] > DFILE
                                }
                            }
                        } else if ((by^2 - 4*ay*cy) >= 0) {
                            # quadratic solution in y
                            TIMES[1] = (-by + sqrt(by^2 - 4*ay*cy)) / (2 * ay)
                            TIMES[2] = (-by - sqrt(by^2 - 4*ay*cy)) / (2 * ay)
                            if (DEBUG > 4) {
                                print "y: TIMES[quad] =", TIMES[1] TIMES[2] > DFILE
                            }
                        } # else no rational solution
                    } # else lines never overlap
                } else {
                    # linear solution in x
                    TIMES[1] = -cx / bx
                    if (DEBUG > 4) {
                        print "x: TIMES[linear] =", TIMES[1] > DFILE
                    }
                }
            } else if ((bx^2 - 4*ax*cx) >= 0) {
                # quadratic solution in x
                TIMES[1] = (-bx + sqrt(bx^2 - 4*ax*cx)) / (2 * ax)
                TIMES[2] = (-bx - sqrt(bx^2 - 4*ax*cx)) / (2 * ax)
                if (DEBUG > 4) {
                    print "x: TIMES[quad] =", TIMES[1] TIMES[2] > DFILE
                }
            } # else no rational solution
            for (time in TIMES) {
                t = TIMES[time]
                if (t < 0) {
                    continue
                }
                if (DEBUG > 4) {
                    print "at", t, "x=", ax*t^2 + bx*t + cx, "y=", ay*t^2 + by*t + cy, "z=", az*t^2 + bz*t + cz > DFILE
                }
                if (fzero(ay * t^2 + by * t + cy) && fzero(az * t^2 + bz * t + cz)) {
                    if (DEBUG) {
                        print RULE[i], "and", RULE[j], "collide at", t > DFILE
                    }
                    COLLISIONS[t][i] = COLLISIONS[t][j] = 1
                }
            }
        }
    }
    split("", DESTROYED)
    for (t in COLLISIONS) {
        num_particles_colliding = 0
        for (p in COLLISIONS[t]) {
            if (!(p in DESTROYED)) {
                ++num_particles_colliding
            }
        }
        if (num_particles_colliding < 2) {
            continue
        }
        for (p in COLLISIONS[t]) if (!(p in DESTROYED)) {
            if (DEBUG) {
                print p, "DESTROYED at", t > DFILE
            }
            DESTROYED[p] = 1
        }
    }
    print NR - length(DESTROYED)
}
