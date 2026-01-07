#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
($0 !~ /^[[:digit:]]+$/) {
    aoc::data_error()
}
{
    split("", GRID)
    x = y = 0
    GRID[x,y] = 1
    for (i = 2; i <= $1; ++i) {
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
        GRID[x,y] = 1
    }
    print ((x < 0) ? -x : x) + ((y < 0) ? -y : y)
}
