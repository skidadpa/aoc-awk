#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
($0 !~ /^[[:digit:]]+$/) {
    aoc::data_error()
}
function sum_adjacents(GRID,x,y,   result) {
    result = 0
    for (dx = -1; dx <= 1; ++dx) {
        for (dy = -1; dy <= 1; ++dy) {
            if (((x + dx) SUBSEP (y + dy)) in GRID) {
                result += GRID[x + dx, y + dy]
            }
        }
    }
    return result
}
{
    split("", GRID)
    x = y = 0
    last_written = 1
    GRID[x,y] = 1
    for (i = 2; last_written <= $1; ++i) {
        switch (8*(((x-1) SUBSEP y) in GRID) + 4*(((x+1) SUBSEP y) in GRID) + 2*((x SUBSEP (y-1)) in GRID) + ((x SUBSEP (y+1)) in GRID)) {
        case 10: // left  && !right && top  && !bottom
            ++x
            break
        case 9:  // left  && !right && !top && bottom
            --y
            break
        case 8:  // left  && !right && !top && !bottom
            --y
            break
        case 7:  // !left && right  && top  && bottom
            --x
            break
        case 6:  // !left && right  && top  && !bottom
            ++y
            break
        case 5:  // !left && right  && !top && bottom
            --x
            break
        case 4:  // !left && right  && !top && !bottom
            ++y
            break
        case 2:  // !left && !right && top  && !bottom
            ++x
            break
        case 1:  // !left && !right && !top && bottom
            --x
            break
        case 0:  // !left && !right && !top && !bottom
            ++x
            break
        default:
            aoc::compute_error("unexpected " left "," right "," top "," bottom)
        }
        last_written = GRID[x,y] = sum_adjacents(GRID,x,y)
    }
    print last_written
}
