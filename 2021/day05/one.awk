#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
{
    n1 = split($1, p1, ",")
    n2 = split($3, p2, ",")
    if (n1 != 2 || n2 != 2) { aoc::data_error() }
    x1 = p1[1]
    y1 = p1[2]
    x2 = p2[1]
    y2 = p2[2]
    if (x1 == x2) {
        if (y1 > y2) for (y = y1; y >= y2; --y) ++map[x1, y]
        else for (y = y1; y <= y2; ++y) ++map[x1, y]
    } else if (y1 == y2) {
        if (x1 > x2) for (x = x1; x >= x2; --x) ++map[x, y1]
        else for (x = x1; x <= x2; ++x) ++map[x, y1]
    }
}
END {
    overlaps = 0
    for (coordinate in map) if (map[coordinate] > 1) ++overlaps
    print overlaps
}
