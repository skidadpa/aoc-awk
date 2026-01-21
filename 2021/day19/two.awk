#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function coords(b) {
    return b "[" X[b] "," Y[b] "," Z[b] "]"
}
function cdiffs(b0, b) {
    return "<" X[b] - X[b0] "," Y[b] - Y[b0] "," Z[b] - Z[b0] ">"
}
function sinfo(s) {
    return s "[" SX[s] "," SY[s] "," SZ[s] "](" SO[s] ")"
}
function dist(b1, b2) {
    return aoc::manhattan(X[b1], X[b2], Y[b1], Y[b2], Z[b1], Z[b2])
}
function sdist(b1, b2) {
    return aoc::manhattan(SX[b1], SX[b2], SY[b1], SY[b2], SZ[b1], SZ[b2])
}
function unmap(map, coord, b) {
    switch (index(map, coord)) {
    case 1:
        return X[b]
    case 2:
        return Y[b]
    case 3:
        return Z[b]
    default:
        switch (index(map, toupper(coord))) {
        case 1:
            return -X[b]
        case 2:
            return -Y[b]
        case 3:
            return -Z[b]
        default:
            aoc::compute_error("illegal unmapping: " map "," coord)
        }
    }
}
function orientation_map(b1, c1, b2, c2,   x1, y1, z1, x2, y2, z2) {
    x1 = X[c1]-X[b1]
    y1 = Y[c1]-Y[b1]
    z1 = Z[c1]-Z[b1]
    x2 = X[c2]-X[b2]
    y2 = Y[c2]-Y[b2]
    z2 = Z[c2]-Z[b2]
    if (aoc::abs(x1) == aoc::abs(x2)) {
        if ((aoc::abs(y1) == aoc::abs(y2)) && (aoc::abs(z1) == aoc::abs(z2))) {
            return ((x1==x2) ? "x" : "X") ((y1 == y2) ? "y" : "Y") ((z1 == z2) ? "z" : "Z")
        }
        if ((aoc::abs(y1) == aoc::abs(z2)) && (aoc::abs(z1) == aoc::abs(y2))) {
            return ((x1==x2) ? "x" : "X") ((y1 == z2) ? "z" : "Z") ((z1 == y2) ? "y" : "Y")
        }
    }
    if (aoc::abs(x1) == aoc::abs(y2)) {
        if ((aoc::abs(y1) == aoc::abs(z2)) && (aoc::abs(z1) == aoc::abs(x2))) {
            return ((x1==y2) ? "y" : "Y") ((y1 == z2) ? "z" : "Z") ((z1 == x2) ? "x" : "X")
        }
        if ((aoc::abs(y1) == aoc::abs(x2)) && (aoc::abs(z1) == aoc::abs(z2))) {
            return ((x1==y2) ? "y" : "Y") ((y1 == x2) ? "x" : "X") ((z1 == z2) ? "z" : "Z")
        }
    }
    if (aoc::abs(x1) == aoc::abs(z2)) {
        if ((aoc::abs(y1) == aoc::abs(y2)) && (aoc::abs(z1) == aoc::abs(x2))) {
            return ((x1==z2) ? "z" : "Z") ((y1 == y2) ? "y" : "Y") ((z1 == x2) ? "x" : "X")
        }
        if ((aoc::abs(y1) == aoc::abs(x2)) && (aoc::abs(z1) == aoc::abs(y2))) {
            return ((x1==z2) ? "z" : "Z") ((y1 == x2) ? "x" : "X") ((z1 == y2) ? "y" : "Y")
        }
    }
    return ""
}
BEGIN {
    FPAT="(-?[0-9]+)";
    PROCINFO["sorted_in"] = "@ind_num_asc"
    LAST_SCANNER = -1
}
/^--- scanner [0-9]+ ---$/ {
    if (++LAST_SCANNER != $1) { aoc::data_error("scanner definition " $1 " out of order") }
    next
}
/^-?[0-9]+,-?[0-9]+,-?[0-9]+$/ {
    X[NR] = $1
    Y[NR] = $2
    Z[NR] = $3
    SCANS[LAST_SCANNER][NR] = $1 SUBSEP $2 SUBSEP $3
    if (!(LAST_SCANNER in FIRST_SCAN)) {
        FIRST_SCAN[LAST_SCANNER] = NR
    }
    LAST_SCAN[LAST_SCANNER] = NR
    next
}
/^$/ {
    next
}
{ aoc::data_error() }
END {
    #
    # compute manhattan distance between all pairs of scanned beacons
    #
    for (s in SCANS) {
        if (DEBUG > 9) {
            print "from scanner", s > DFILE
        }
        for (b1 = FIRST_SCAN[s]; b1 < LAST_SCAN[s]; ++b1) {
            for (b2 = b1 + 1; b2 <= LAST_SCAN[s]; ++b2) {
                d = dist(b1, b2)
                DISTANCES[s][b1][d][b2] = DISTANCES[s][b2][d][b1] = d
                if (DEBUG > 9) {
                    print coords(b1), "is distance", d, "from", coords(b2) > DFILE
                }
            }
        }
        UNMAPPED[s] = 1
    }

    #
    # set s0 as [0,0,0](xyz) and mark its beacon locations in s0-space
    #
    SX[0] = 0
    SY[0] = 0
    SZ[0] = 0
    SO[0] = "xyz"
    for (b in SCANS[0]) {
        ++BEACONS[X[b], Y[b], Z[b]]
    }
    delete UNMAPPED[0]

    while (length(UNMAPPED) > 0) {
        split("", MAPPED)
        for (s in UNMAPPED) {
            split("", EQUIVALENCES)
            for (b in DISTANCES[s]) {
                for (b0 in DISTANCES[0]) {
                    if (DEBUG > 10) {
                        print "Trying", coords(b0), "and", coords(b) > DFILE
                        printf "%s:", coords(b0) > DFILE
                        for (d in DISTANCES[0][b0]) {
                            printf " %d", d
                        }
                        printf "\n" > DFILE
                        printf "%s:", coords(b) > DFILE
                        for (d in DISTANCES[s][b]) {
                            printf " %d", d
                        }
                        printf "\n" > DFILE
                    }
                    split("", MAPS)
                    for (d in DISTANCES[s][b]) if (d in DISTANCES[0][b0]) {
                        for (c in DISTANCES[s][b][d]) for (c0 in DISTANCES[0][b0][d]) {
                            map = orientation_map(b, c, b0, c0)
                            if (DEBUG > 9) {
                                print cdiffs(c,b), cdiffs(c0,b0), "MAPS", coords(b0) ":" coords(c0), "and", coords(b) ":" coords(c), "AS", map > DFILE
                            }
                            if (map) {
                                if (DEBUG > 1) {
                                    print coords(b0) ":" coords(c0) cdiffs(b0,c0), "and", cdiffs(b,c) coords(b) ":" coords(c), "yield map", map > DFILE
                                }
                                MAPS[map][c,b0] = 1
                            }
                        }
                    }
                    for (map in MAPS) if (length(MAPS[map]) >= 3) {
                        if (s in MAPPED) {
                            aoc::compute_error(s " maps as both " MAPPED[s] " and " map)
                        }
                        MAPPED[s] = map
                    }
                    if (s in MAPPED) {
                        EQUIVALENCES[b0] = b
                        break
                    }
                }
                if (s in MAPPED) {
                    break
                }
            }
            if (s in MAPPED) {
                map = MAPPED[s]
                SO[s] = map
                for (b0 in EQUIVALENCES) {
                    b = EQUIVALENCES[b0]
                    x = X[b0] - unmap(map, "x", b)
                    y = Y[b0] - unmap(map, "y", b)
                    z = Z[b0] - unmap(map, "z", b)
                    if ((s in SX) && ((x != SX[s]) || (y != SY[s]) || (z != SZ[s]))) {
                        aoc::compute_error("after " coords(b0) " to " coords(b) ", " sinfo(s) " became [" x "," y "," z "]")
                    }
                    SX[s] = x
                    SY[s] = y
                    SZ[s] = z
                    if (DEBUG > 1) {
                        print "beacons", coords(b0), "and", coords(b), "(" unmap(map, "x", b) "," unmap(map, "y", b) "," unmap(map, "z", b) ") yields", sinfo(s) > DFILE
                    }
                }
                for (b in SCANS[s]) {
                    # find new coordinates for all beacons and distance to all currently mapped beacons:
                    x = SX[s] + unmap(map, "x", b)
                    y = SY[s] + unmap(map, "y", b)
                    z = SZ[s] + unmap(map, "z", b)
                    X[b] = x
                    Y[b] = y
                    Z[b] = z
                    for (b0 in SCANS[0]) {
                        d = dist(b0, b)
                        DISTANCES[0][b0][d][b] = DISTANCES[0][b][d][b0] = d
                    }
                    # also import existing scan distances from newly-mapped scanner:
                    for (d in DISTANCES[s][b]) {
                        for (c in DISTANCES[s][b][d]) {
                            DISTANCES[0][b][d][c] = DISTANCES[s][b][d][c]
                        }
                    }
                }
                # update SCANS[0] last and make sure beacon locations are marked:
                for (b in SCANS[s]) {
                    c = X[b] SUBSEP Y[b] SUBSEP Z[b]
                    SCANS[0][b] = c
                    ++BEACONS[c]
                }
                delete SCANS[s]
                delete DISTANCES[s]
            }
        }

        for (s in MAPPED) {
            delete UNMAPPED[s]
        }

        if (length(MAPPED) < 1) {
            aoc::compute_error("mapping stalled with " length(UNMAPPED) " unmapped scanners")
        }
    }

    if (DEBUG > 4) {
        print length(BEACONS), "beacons mapped:" > DFILE
        for (b in X) {
            c = X[b] SUBSEP Y[b] SUBSEP Z[b]
            print coords(b), "(" ((c in BEACONS) ? BEACONS[X[b],Y[b],Z[b]] : "unmapped") ")" > DFILE
        }
    }

    if (DEBUG) {
        print length(SX), "sensors mapped:" > DFILE
        for (s in SX) {
            print sinfo(s) > DFILE
        }
    }

    max_distance = 0
    for (s1 = 0; s1 < LAST_SCANNER; ++s1) {
        for (s2 = s1 + 1; s2 <= LAST_SCANNER; ++s2) {
            distance = sdist(s1, s2)
            if (DEBUG) {
                print sinfo(s1), "->", sinfo(s2), "==", distance
            }
            if (max_distance < distance) {
                max_distance = distance
            }
        }
    }
    print max_distance
}
