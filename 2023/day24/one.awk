#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function crosses_at(line, a0, va, b0, vb) {
    return b0 + (line - a0) * vb / va
}
function hits_in_future(line, a0, va) {
    return (va > 0) ? (line >= a0) : (va < 0) ? (line <= a0) : (line == a0)
}
BEGIN {
    FPAT = "-?[[:digit:]]+"
    min = 7
    max = 27
}
NF != 6 {
    aoc::data_error()
}
($4 == 0) || ($5 == 0) || ($6 == 0) {
    aoc::data_error("unsupported axial path")
}
(min == 7) && ($1 > 100) {
    if (NR != 1) {
        aoc::data_error("min/max changed after first entry")
    }
    min = 200000000000000
    max = 400000000000000 
}
{
    x0[NR] = $1
    y0[NR] = $2
    z0[NR] = $3
    vx[NR] = $4
    vy[NR] = $5
    vz[NR] = $6
    yleft = crosses_at(min, $1, $4, $2, $5)
    yright = crosses_at(max, $1, $4, $2, $5)
    xbottom = crosses_at(min, $2, $5, $1, $4)
    xtop = crosses_at(max, $2, $5, $1, $4)
    cross_left = hits_in_future(min, $1, $4) && (yleft >= min) && (yleft <= max)
    cross_right = hits_in_future(max, $1, $4) && (yright >= min) && (yright <= max)
    cross_bottom = hits_in_future(min, $2, $5) && (xbottom >= min) && (xbottom <= max)
    cross_top = hits_in_future(max, $2, $5) && (xtop >= min) && (xtop <= max)
    ylefts[NR] = yleft
    yrights[NR] = yright
    xbottoms[NR] = xbottom
    xtops[NR] = xtop
    in_left[NR] = cross_left
    in_right[NR] = cross_right
    in_bottom[NR] = cross_bottom
    in_top[NR] = cross_top
    if (cross_bottom || cross_top || cross_left || cross_right) {
        edges_crossed[NR] = cross_left*8 + cross_right*4 + cross_bottom*2 + cross_top
    }
}
function paths_intersect(a, b,    i, j, k, l) {
    switch (edges_crossed[a]) {
    case 15:
    case 14:
    case 13:
    case 12: # left to right
        switch (edges_crossed[b]) {
        case 15:
        case 11:
        case 7:
        case 3: # top to bottom
            return 1

        case 14:
        case 13:
        case 12: # left to right
            return ((ylefts[a] <= ylefts[b]) && (yrights[a] >= yrights[b])) || ((ylefts[a] >= ylefts[b]) && (yrights[a] <= yrights[b]))

        case 10: # left to bottom
            return (ylefts[a] <= ylefts[b])

        case 9: # left to top
            return (ylefts[a] >= ylefts[b])

        case 6: # right to bottom
            return (yrights[a] <= yrights[b])

        case 5: # right to top
            return (yrights[a] >= yrights[b])

        case 8:
        case 4:
        case 2:
        case 1:
        case 0:
        default:
            aoc::compute_error("invalid edges value " edges_crossed[a])
        }
        break

    case 11:
    case 7:
    case 3: # top to bottom
        switch (edges_crossed[b]) {
        case 15:
        case 14:
        case 13:
        case 12: # left to right
            return 1

        case 11:
        case 7:
        case 3: # top to bottom
            return ((ytops[a] <= ytops[b]) && (ybottoms[a] >= ybottoms[b])) || ((ytops[a] >= ytops[b]) && (ybottoms[a] <= ybottoms[b]))

        case 10: # left to bottom
            return (ybottoms[a] <= ybottoms[b])

        case 9: # left to top
            return (ytops[a] <= ytops[b])

        case 6: # right to bottom
            return (ybottoms[a] >= ybottoms[b])

        case 5: # right to top
            return (ytops[a] >= ytops[b])

        case 8:
        case 4:
        case 2:
        case 1:
        case 0:
        default:
            aoc::compute_error("invalid edges value " edges_crossed[a])
        }
        break

    case 10: # left to bottom
        switch (edges_crossed[b]) {
        case 15:
        case 14:
        case 13:
        case 12: # left to right
            return (ylefts[a] >= ylefts[b])

        case 11:
        case 7:
        case 3: # top to bottom
            return (ybottoms[a] >= ybottoms[b])

        case 10: # left to bottom
            return ((ylefts[a] <= ylefts[b]) && (ybottoms[a] >= ybottoms[b])) || ((ylefts[a] >= ylefts[b]) && (ybottoms[a] <= ybottoms[b]))

        case 9: # left to top
            return (ylefts[a] >= ylefts[b])

        case 6: # right to bottom
            return (ybottoms[a] >= ybottoms[b])

        case 5: # right to top
            return 0

        case 8:
        case 4:
        case 2:
        case 1:
        case 0:
        default:
            aoc::compute_error("invalid edges value " edges_crossed[a])
        }
        break

    case 9: # left to top
        switch (edges_crossed[b]) {
        case 15:
        case 14:
        case 13:
        case 12: # left to right
            return (ylefts[a] <= ylefts[b])

        case 11:
        case 7:
        case 3: # top to bottom
            return (ytops[a] >= ytops[b])

        case 10: # left to bottom
            return (ylefts[a] <= ylefts[b])

        case 9: # left to top
            return ((ylefts[a] <= ylefts[b]) && (ytops[a] <= ytops[b])) || ((ylefts[a] >= ylefts[b]) && (ytops[a] >= ytops[b]))

        case 6: # right to bottom
            return 0

        case 5: # right to top
            return (ytops[a] >= ytops[b])

        case 8:
        case 4:
        case 2:
        case 1:
        case 0:
        default:
            aoc::compute_error("invalid edges value " edges_crossed[a])
        }
        break

    case 6: # right to bottom
        switch (edges_crossed[b]) {
        case 15:
        case 14:
        case 13:
        case 12: # left to right
            return (yrights[a] >= yrights[b])

        case 11:
        case 7:
        case 3: # top to bottom
            return (ybottoms[a] <= ybottoms[b])

        case 10: # left to bottom
            return (ybottoms[a] <= ybottoms[b])

        case 9: # left to top
            return 0

        case 6: # right to bottom
            return ((yrights[a] <= yrights[b]) && (ybottoms[a] <= ybottoms[b])) || ((yrights[a] >= yrights[b]) && (ybottoms[a] >= ybottoms[b]))

        case 5: # right to top
            return (yrights[a] >= yrights[b])

        case 8:
        case 4:
        case 2:
        case 1:
        case 0:
        default:
            aoc::compute_error("invalid edges value " edges_crossed[a])
        }
        break

    case 5: # right to top
        switch (edges_crossed[b]) {
        case 15:
        case 14:
        case 13:
        case 12: # left to right
            return (yrights[a] <= yrights[b])

        case 11:
        case 7:
        case 3: # top to bottom
            return (ytops[a] <= ytops[b])

        case 10: # left to bottom
            return 0

        case 9: # left to top
            return (ytops[a] <= ytops[b])

        case 6: # right to bottom
            return (yrights[a] <= yrights[b])

        case 5: # right to top
            return ((yrights[a] <= yrights[b]) && (ytops[a] >= ytops[b])) || ((yrights[a] >= yrights[b]) && (ytops[a] <= ytops[b]))

        case 8:
        case 4:
        case 2:
        case 1:
        case 0:
        default:
            aoc::compute_error("invalid edges value " edges_crossed[a])
        }
        break

    case 8:
    case 4:
    case 2:
    case 1:
    case 0:
    default:
        aoc::compute_error("invalid edges value " edges_crossed[a])
    }
}
    # edges_crossed[NR] = cross_left*8 + cross_right*4 + cross_bottom*2 + cross_top
END {
    num_intersections = 0
    num_candidates = asorti(edges_crossed, candidates)
    for (a = 1; a < num_candidates; ++a) {
        for (b = a + 1; b <= num_candidates; ++b) {
            if (paths_intersect(candidates[a], candidates[b])) {
                ++num_intersections
            }
        }
    }
    print num_intersections
}
