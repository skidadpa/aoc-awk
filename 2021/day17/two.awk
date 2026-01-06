#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FS = "[,=]" }
(NF != 4) { aoc::data_error() }
{
    if (split($2, xcoords, "\\.\\.") != 2 || split($4, ycoords, "\\.\\.") != 2 ||
        xcoords[1] > xcoords[2] || ycoords[1] > ycoords[2] ||
        xcoords[2] <= 0 || ycoords[2] >= 0) { aoc::data_error() }
    xmin = xcoords[1]; xmax = xcoords[2]; ymin = ycoords[1]; ymax = ycoords[2]
    for (vXmin = int(sqrt(xmin))+1; vXmin * (vXmin+1) / 2 <= xmax; ++vXmin)
        if (vXmin * (vXmin + 1) / 2 >= xmin) break
    vXmax = xmax
    vYmin = ymin
    vYmax = -ymin - 1
    for (vX = vXmin; vX <= vXmax; ++vX) for (vY = vYmin; vY <= vYmax; ++vY) {
        y = x = 0; dX = vX; dY = vY
        while (x <= xmax && y >= ymin) {
            if (x >= xmin && y <= ymax) { valid[vX,vY] = 1; break }
            y += dY; x += dX
            --dY; if (dX > 0) --dX
        }
    }

}
END {
    print length(valid)
}
