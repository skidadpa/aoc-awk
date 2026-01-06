#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FPAT="([-0-9]+)"; nscan = -1 }
(NF == 0) { next }
(NF != 3) { aoc::data_error() }
/^--- scanner [0-9]+ ---$/ {
    if (nscan >= $2) { aoc::data_error() }
    nscan = $2
    next
}
function map(x, y, z, o) {
    x = x+0; y = y+0; z = z+0
    switch (o) {
    case 1: return (x) SUBSEP (y) SUBSEP (z)
    case 2: return (x) SUBSEP (-z) SUBSEP (y)
    case 3: return (x) SUBSEP (-y) SUBSEP (-z)
    case 4: return (x) SUBSEP (z) SUBSEP (-y)
    case 5: return (y) SUBSEP (-x) SUBSEP (z)
    case 6: return (y) SUBSEP (-z) SUBSEP (-x)
    case 7: return (y) SUBSEP (x) SUBSEP (-z)
    case 8: return (y) SUBSEP (z) SUBSEP (x)
    case 9: return (-x) SUBSEP (-y) SUBSEP (z)
    case 10: return (-x) SUBSEP (-z) SUBSEP (-y)
    case 11: return (-x) SUBSEP (y) SUBSEP (-z)
    case 12: return (-x) SUBSEP (z) SUBSEP (y)
    case 13: return (-y) SUBSEP (x) SUBSEP (z)
    case 14: return (-y) SUBSEP (-z) SUBSEP (x)
    case 15: return (-y) SUBSEP (-x) SUBSEP (-z)
    case 16: return (-y) SUBSEP (z) SUBSEP (-x)
    case 17: return (z) SUBSEP (x) SUBSEP (y)
    case 18: return (z) SUBSEP (y) SUBSEP (-x)
    case 19: return (z) SUBSEP (-x) SUBSEP (-y)
    case 20: return (z) SUBSEP (-y) SUBSEP (x)
    case 21: return (-z) SUBSEP (-y) SUBSEP (-x)
    case 22: return (-z) SUBSEP (x) SUBSEP (-y)
    case 23: return (-z) SUBSEP (y) SUBSEP (x)
    case 24: return (-z) SUBSEP (-x) SUBSEP (y)
    default: aoc::compute_error()
    }
}
{ for (o = 1; o <= 24; ++o) scanner[nscan,o][map($1,$2,$3,o)] = avail[nscan,o] = 1 }
function addcoords(a, b,    ca, cb) {
    split(a, ca, SUBSEP)
    split(b, cb, SUBSEP)
    return (ca[1]+cb[1]) SUBSEP (ca[2]+cb[2]) SUBSEP (ca[3]+cb[3])
}
function negcoords(a,    cab) {
    split(a, ca, SUBSEP)
    return (0-ca[1]) SUBSEP (0-ca[2]) SUBSEP (0-ca[3])
}
function set_offset(s, p) {
    offset[s] = negcoords(p)
    return s
}
function find(    l, m, s, scanned, toscan, p, off, q, count) {
    for (l in locations) {
        if (checked[l])  continue
        for (m in locations[l]) {
            if ((l,m) in checked) continue
            for (s in avail) {
                scanned = 0
                toscan = length(scanner[s]) - 11
                for (p in scanner[s]) if (++scanned <= toscan) {
                    off = addcoords(p, negcoords(m))
                    count = 0
                    for (q in locations[l])
                        if (addcoords(q, off) in scanner[s])
                        if (++count >= 12)
                        return set_offset(s, off)
                }
            }
            checked[l,m] = 1
        }
        checked[l] = 1
    }
    aoc::compute_error()
}
function register(s,    p, info, o) {
    # print "REGISTERING", gensub(SUBSEP, "(", 1, s) ") AT", gensub(SUBSEP, ",", "g", offset[s]) > DFILE
    for (p in scanner[s]) locations[s][addcoords(offset[s],p)] = 1
    split(s, info, SUBSEP)
    for (o = 1; o <= 24; ++o) { delete avail[info[1],o] }
}
function manhattan(a, b,    ca, cb, x, y, z) {
    split(a, ca, SUBSEP)
    split(b, cb, SUBSEP)
    x = (ca[1] - cb[1]); if (x < 0) x = -x
    y = (ca[2] - cb[2]); if (y < 0) y = -y
    z = (ca[3] - cb[3]); if (z < 0) z = -z
    return x + y + z
}
END {
    offset[0,1] = 0 SUBSEP 0 SUBSEP 0
    register(0 SUBSEP 1)
    while (length(avail)) register(find())
    for (l in locations) for (p in locations[l]) all[p] = 1
    for (s1 in offset) for (s2 in offset) {
        if (s1 != s2 && !((s1,s2) in distance) && !((s2,s1) in distance)) {
            distance[s1,s2] = manhattan(offset[s1], offset[s2])
            if (distance[s1,s2] > max) max = distance[s1,s2]
        }
    }
    print max
}
