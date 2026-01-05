#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
    width = height = 0
}
/^Filesystem +Size +Used +Avail +Use%$/ {
    output_started = 1
    next
}
!output_started {
    next
}
(NF != 6) {
    aoc::data_error("invalid output")
}
{
    if ($4 + $5 != $3) {
        aoc::data_error("sizes don't match")
    }
    if (width <= $1) {
        width = $1 + 1
    }
    if (height <= $2) {
        height = $2 + 1
    }
    SIZE[$1,$2] = $3
    USED[$1,$2] = $4
    AVAIL[$1,$2] = $5
    if (!$4) {
        if (empty_square) {
            aoc::compute_error("program only handles one empty square")
        }
        empty_square = $1 SUBSEP $2
    }
    if ($4 < 400) {
        if (!min_sm_used || ($4 && (USED[min_sm_used] > $4))) {
            min_sm_used = $1 SUBSEP $2
        }
        if (!max_sm_used || (USED[max_sm_used] < $4)) {
            max_sm_used = $1 SUBSEP $2
        }
        if (!min_sm_disk || (SIZE[min_sm_disk] > $3)) {
            min_sm_disk = $1 SUBSEP $2
        }
        if (!max_sm_disk || (SIZE[max_sm_disk] < $3)) {
            max_sm_disk = $1 SUBSEP $2
        }
    } else {
        if (!min_lg_used || (USED[min_lg_used] > $4)) {
            min_lg_used = $1 SUBSEP $2
        }
        if (!max_lg_used || (USED[max_lg_used] < $4)) {
            max_lg_used = $1 SUBSEP $2
        }
        if (!min_lg_disk || (SIZE[min_lg_disk] > $3)) {
            min_lg_disk = $1 SUBSEP $2
        }
        if (!max_lg_disk || (SIZE[max_lg_disk] < $3)) {
            max_lg_disk = $1 SUBSEP $2
        }
    }
}
function dump(empty_square, has_data,   x, y, code, left, right) {
    for (y = 0; y < height; ++y) {
        for (x = 0; x < width; ++x) {
            if (x + y == 0) {
                if (x SUBSEP y == has_data) {
                    left = "{"
                    right = "}"
                } else {
                    left = "("
                    right = ")"
                }
            } else if (x SUBSEP y == has_data) {
                left = "["
                right = "]"
            } else {
                left = right = " "
            }
            if (USED[x,y] >= 400) {
                printf("%cX%c", left, right) > DFILE
            } else if (x SUBSEP y == empty_square) {
                printf("%c_%c", left, right) > DFILE
            } else {
                printf("%c.%c", left, right) > DFILE
            }
        }
        printf("\n") > DFILE
    }
}
function dist_to_top(x, y,   d, i) {
    d = 0
    while ((y >= 0) && (USED[x,y] < 400)) {
        ++d
        --y
    }
    if (y <= 0) {
        return d - 1
    }
    for (i = 1; i < width; ++i) {
        if ((x - i >= 0) && (USED[x-i, y] < 400)) {
            x -= i
            break
        } else if ((x + i >= 0) && (USED[x+i, y] < 400)) {
            x += i
            break
        }
    }
    return d + i + dist_to_top(x, y)
}
function pos_at_top(x, y,   d, i) {
    while ((y >= 0) && (USED[x,y] < 400)) {
        --y
    }
    if (y <= 0) {
        return x
    }
    for (i = 1; i < width; ++i) {
        if ((x - i >= 0) && (USED[x-i, y] < 400)) {
            x -= i
            break
        } else if ((x + i >= 0) && (USED[x+i, y] < 400)) {
            x += i
            break
        }
    }
    return pos_at_top(x,y)
}
END {
    target = 0 SUBSEP 0
    has_data = (width - 1) SUBSEP 0
    if (DEBUG) {
        print "INITIAL LAYOUT" > DFILE
        dump(empty_square, has_data)
    }
    if (length(SIZE) != width * height) {
        aoc::data_error(width "x" height "=" width * height "!=" length(SIZE))
    }
    if (2 * USED[min_sm_used] <= SIZE[max_sm_disk]) {
        aoc::data_error("disk " SIZE[max_sm_disk] " fits 2 of " USED[min_sm_used])
    }
    if (USED[max_sm_used] > SIZE[min_sm_disk]) {
        aoc::data_error("disk " SIZE[min_sm_disk] " doesn't fit " USED[max_sm_used])
    }
    if (min_lg_used) {
        if (2 * USED[min_lg_used] <= SIZE[max_lg_disk]) {
            aoc::data_error("disk " SIZE[max_lg_disk] " fits 2 of " USED[min_lg_used])
        }
        if (USED[max_lg_used] > SIZE[min_lg_disk]) {
            aoc::data_error("disk " SIZE[min_lg_disk] " doesn't fit " USED[max_lg_used])
        }
    }
    if (!empty_square) {
        aoc::compute_error("program requires one empty square")
    }
    for (x = 0; x < width; ++x) {
        if ((USED[x,0] >= 400) || (USED[x,1] >= 400)) {
            aoc::compute_error("program only handles direct data -> target path")
        }
    }
    split(empty_square, coords, SUBSEP)
    x = coords[1]
    y = coords[2]
    dist = dist_to_top(x,y)
    x = pos_at_top(x,y)
    if (DEBUG) {
        print "MOVE TO TOP, dist =", dist > DFILE
        dump(x SUBSEP 0, has_data)
    }
    dist += width - 1 - x
    x = width - 1
    if (DEBUG) {
        print "MOVE TO RIGHT, dist =", dist > DFILE
        dump(x SUBSEP 0, (x - 1) SUBSEP 0)
    }
    dist += 5 * (width - 2)
    if (DEBUG) {
        print "MOVE TO LEFT, dist =", dist > DFILE
        dump(1 SUBSEP 0, 0 SUBSEP 0)
    }
    print dist
}
