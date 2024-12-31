#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function count_matches(s,   f, b) { split(s, f, "XMAS")
                                    split(s, b, "SAMX")
                                    return length(f) + length(b) - 2 }
BEGIN {
    FS = ""
}
{
    for (i = 1; i <= NF; ++i) {
        PUZZLE[i,NR] = $i
    }
}
END {
    for (xy in PUZZLE) {
        if (PUZZLE[xy] == "A") {
            split(xy, coords, SUBSEP)
            x = coords[1]
            y = coords[2]
            if (((PUZZLE[x-1,y-1] == "M") && (PUZZLE[x+1,y+1] == "S")) ||
                ((PUZZLE[x-1,y-1] == "S") && (PUZZLE[x+1,y+1] == "M"))) {
                if (((PUZZLE[x+1,y-1] == "M") && (PUZZLE[x-1,y+1] == "S")) ||
                    ((PUZZLE[x+1,y-1] == "S") && (PUZZLE[x-1,y+1] == "M"))) {
                        ++matches
                }
            }
        }
    }
    print matches
}
