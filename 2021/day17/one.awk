#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FS = "[,=]" }
(NF != 4) { aoc::data_error() }
{
    if (split($2, xcoords, "\\.\\.") != 2 || split($4, ycoords, "\\.\\.") != 2 ||
        xcoords[1] > xcoords[2] || ycoords[1] > ycoords[2] ||
        xcoords[2] <= 0 || ycoords[2] >= 0) { aoc::data_error() }
    vY = -ycoords[1] - 1
    print vY * (vY + 1) / 2
}
