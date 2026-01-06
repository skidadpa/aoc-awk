#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    hx = hy = tx = ty = 0
    VISITED[tx,ty] = 1
}
function move_tail() {
    if (hx == tx) {
        if (hy - ty > 1) {
            ++ty
        } else if (ty - hy > 1) {
            --ty
        }
    } else if (hy == ty) {
        if (hx - tx > 1) {
            ++tx
        } else if (tx - hx > 1) {
            --tx
        }
    } else if ((hy > ty) && (hx > tx)) {
        if ((hy - ty > 1) || (hx - tx > 1)) {
            ++ty
            ++tx
        }
    } else if ((ty > hy) && (tx > hx)) {
        if ((ty - hy > 1) || (tx - hx > 1)) {
            --ty
            --tx
        }
    } else if ((hy > ty) && (tx > hx)) {
        if ((hy - ty > 1) || (tx - hx > 1)) {
            ++ty
            --tx
        }
    } else if ((ty > hy) && (hx > tx)) {
        if ((ty - hy > 1) || (hx - tx > 1)) {
            --ty
            ++tx
        }
    } else {
        aoc::compute_error()
    }
    ++VISITED[tx,ty]
}
/^R [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        ++hx
        move_tail()
    }
    next
}
/^U [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        ++hy
        move_tail()
    }
    next
}
/^L [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        --hx
        move_tail()
    }
    next
}
/^D [[:digit:]]+$/ {
    for (i = 1; i <= $2; ++i) {
        --hy
        move_tail()
    }
    next
}
{
    aoc::data_error()
}
END {
    print length(VISITED)
}
