#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF < 4 || NF > 5) { aoc::data_error() }
(NF == 4) {
    f = split($2, from, ","); t = split($4, to, ",")
    if ($1 != "toggle" || $3 != "through" || f != 2 || t != 2) {
        aoc::data_error()
    }
    for (x = from[1]; x <= to[1]; ++x)
        for (y = from[2]; y <= to[2]; ++y)
            if ((x,y) in grid) delete grid[x,y]; else grid[x,y] = 1
}
(NF == 5) {
    f = split($3, from, ","); t = split($5, to, ",")
    if ($1 != "turn" || $4 != "through" || f != 2 || t != 2) {
        aoc::data_error()
    }
    if ($2 == "on") {
        for (x = from[1]; x <= to[1]; ++x)
            for (y = from[2]; y <= to[2]; ++y)
                grid[x,y] = 1
    } else if ($2 == "off") {
        for (x = from[1]; x <= to[1]; ++x)
            for (y = from[2]; y <= to[2]; ++y)
                delete grid[x,y]
    } else { aoc::data_error() }
}
END {
    print length(grid)
}
