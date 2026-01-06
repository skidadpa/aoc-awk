#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
}
(NF != 3) || ($0 !~ /^[[:digit:]]+,[[:digit:]]+,[[:digit:]]+$/) {
    aoc::data_error()
}
{
    CUBES[$1,$2,$3] = 1
}
function exposed_sides(x, y, z,   count) {
    count = 0
    if (!((x-1,y,z) in CUBES)) ++count
    if (!((x+1,y,z) in CUBES)) ++count
    if (!((x,y-1,z) in CUBES)) ++count
    if (!((x,y+1,z) in CUBES)) ++count
    if (!((x,y,z-1) in CUBES)) ++count
    if (!((x,y,z+1) in CUBES)) ++count
    return count
}
END {
    for (c in CUBES) {
        split(c, coords, SUBSEP)
        exposed += exposed_sides(coords[1], coords[2], coords[3])
    }
    print exposed
}
