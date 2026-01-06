#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FPAT = "-?[0-9]+" }
function find_overlaps(    box, b, o, n, i, e) {
    split("", overlaps)
    split("", enclosed)
    for (box in on) {
        split(box, b, SUBSEP)
        if (b[1] >= $1 && b[2] <= $2 && b[3] >= $3 && b[4] <= $4 && b[5] >= $5 && b[6] <= $6) {
            enclosed[box] = 1
            continue
        }
        if (b[2] < $1 || b[1] > $2 || b[4] < $3 || b[3] > $4 || b[6] < $5 || b[5] > $6) continue

        n = split("", o)
        if (b[1] < $1) {
            o[++n] = b[1];   o[++n] = $1 - 1
            o[++n] = b[3];   o[++n] = b[4]
            o[++n] = b[5];   o[++n] = b[6]
            b[1] = $1
        }
        if (b[2] > $2) {
            o[++n] = $2 + 1; o[++n] = b[2]
            o[++n] = b[3];   o[++n] = b[4]
            o[++n] = b[5];   o[++n] = b[6]
            b[2] = $2
        }
        if (b[3] < $3) {
            o[++n] = b[1];   o[++n] = b[2]
            o[++n] = b[3];   o[++n] = $3 - 1
            o[++n] = b[5];   o[++n] = b[6]
            b[3] = $3
        }
        if (b[4] > $4) {
            o[++n] = b[1];   o[++n] = b[2]
            o[++n] = $4 + 1; o[++n] = b[4]
            o[++n] = b[5];   o[++n] = b[6]
            b[4] = $4
        }
        if (b[5] < $5) {
            o[++n] = b[1];   o[++n] = b[2]
            o[++n] = b[3];   o[++n] = b[4]
            o[++n] = b[5];   o[++n] = $5 - 1
            b[5] = $5
        }
        if (b[6] > $6) {
            o[++n] = b[1];   o[++n] = b[2]
            o[++n] = b[3];   o[++n] = b[4]
            o[++n] = $6 + 1; o[++n] = b[6]
            b[6] = $6
        }
        overlaps[box] = o[1]
        for (i = 2; i <= n; ++i) overlaps[box] = overlaps[box] SUBSEP o[i]
        enclosed[b[1],b[2],b[3],b[4],b[5],b[6]] = 1
    }
}
/^off x=-?[0-9]+\.\.-?[0-9]+,y=-?[0-9]+\.\.-?[0-9]+,z=-?[0-9]+\.\.-?[0-9]+$/ {
    if ($1 > $2 || $3 > $4 || $5 > $6) { aoc::data_error() }
    find_overlaps()
    for (i in enclosed) delete on[i]
    for (i in overlaps) {
        delete on[i]
        n = split(overlaps[i], p, SUBSEP)
        for (j = 1; j < n; j += 6) on[p[j],p[j+1],p[j+2],p[j+3],p[j+4],p[j+5]] = 1
    }
    next
}
/^on x=-?[0-9]+\.\.-?[0-9]+,y=-?[0-9]+\.\.-?[0-9]+,z=-?[0-9]+\.\.-?[0-9]+$/ {
    if ($1 > $2 || $3 > $4 || $5 > $6) { aoc::data_error() }
    find_overlaps()
    for (i in enclosed) delete on[i]
    for (i in overlaps) {
        delete on[i]
        n = split(overlaps[i], p, SUBSEP)
        for (j = 1; j < n; j += 6) on[p[j],p[j+1],p[j+2],p[j+3],p[j+4],p[j+5]] = 1
    }
    on[$1,$2,$3,$4,$5,$6] = 1
    next
}
{ aoc::data_error() }
END {
    for (box in on) {
        split(box, b, SUBSEP)
        volume += (1 + b[2] - b[1]) * (1 + b[4] - b[3]) * (1 + b[6] - b[5])
    }
    print volume
}
