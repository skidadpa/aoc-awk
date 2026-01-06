#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = " -> "
    START_X = 500
    START_Y = 0
    LEFT = START_X
    RIGHT = START_X
    BOTTOM = START_Y
    MAP[START_X,START_Y] = "+"
}
function print_map(   x, y) {
    for (y = 0; y <= BOTTOM; ++y) {
        printf("%03d ", y) > DFILE
        for (x = LEFT; x <= RIGHT; ++x) {
            if ((x,y) in MAP) {
                printf("%c", MAP[x,y]) > DFILE
            } else {
                printf(".") > DFILE
            }
        }
        printf("\n") > DFILE
    }
}
function draw_rock(x1, y1, x2, y2,   i) {
    if (DEBUG) printf("draw %d,%d to %d,%d\n", x1, y1, x2, y2) > DFILE
    if (x1 == x2) {
        if (y2 >= y1) {
            for (i = y1; i <= y2; ++i) {
                MAP[x1,i] = "#"
            }
        } else {
            for (i = y2; i <= y1; ++i) {
                MAP[x1,i] = "#"
            }
        }
    } else if (y1 == y2) {
        if (x2 >= x1) {
            for (i = x1; i <= x2; ++i) {
                MAP[i,y1] = "#"
            }
        } else {
            for (i = x2; i <= x1; ++i) {
                MAP[i,y1] = "#"
            }
        }
    } else {
        aoc::data_error()
    }
}
/^[[:digit:]]+,[[:digit:]]+( -> [[:digit:]]+,[[:digit:]]+)*$/ {
    if (DEBUG) {
        print NF, "in", $0 > DFILE
    }
    delete coords
    for (i = 1; i <= NF; ++i) {
        split($i, coords[i], ",")
        if (coords[i][1] < LEFT) {
            LEFT = coords[i][1]
        } else if (coords[i][1] > RIGHT) {
            RIGHT = coords[i][1]
        }
        if (coords[i][2] > BOTTOM) {
            BOTTOM = coords[i][2]
        }
    }
    for (i = 1; i <= NF - 1; ++i) {
        draw_rock(coords[i][1], coords[i][2], coords[i + 1][1], coords[i + 1][2])
    }
    next
}
{
    aoc::data_error()
}
function drop_sand_from(x, y) {
    if ((x < LEFT) || (x > RIGHT) || (y > BOTTOM)) {
        return 0
    }
    if (!((x,y+1) in MAP)) {
        return drop_sand_from(x, y+1)
    } else if (!((x-1,y+1) in MAP)) {
        return drop_sand_from(x-1, y+1)
    } else if (!((x+1,y+1) in MAP)) {
        return drop_sand_from(x+1, y+1)
    } else if ((x,y) in MAP) {
        aoc::compute_error()
    } else {
        MAP[x,y] = "o"
        return 1
    }
}
END {
    if (DEBUG) print_map()
    while (drop_sand_from(START_X, START_Y)) {
        ++sand_caught
        if (DEBUG) {
            printf("\n") > DFILE
            print_map()
        }
    }
    print sand_caught
}
