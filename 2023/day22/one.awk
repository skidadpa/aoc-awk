#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FS="[,~]"
    xmin = xmax = ymin = ymax = 0
}
$0 !~ /^[[:digit:]]+,[[:digit:]]+,[[:digit:]]+~[[:digit:]]+,[[:digit:]]+,[[:digit:]]+$/ {
    aoc::data_error()
}
{
    x0[NR] = $1
    y0[NR] = $2
    z0[NR] = $3
    x1[NR] = $4
    y1[NR] = $5
    z1[NR] = $6
    if (xmin > $1) { xmin = $1 }
    if (ymin > $2) { ymin = $2 }
    if (xmax < $4) { xmax = $4 }
    if (ymax < $5) { ymax = $5 }
}
END {
    for (y = ymin; y <= ymax; ++y) {
        pile[0][x,y] = 0
        height[x,y] = 0
    }
    PROCINFO["sorted_in"] = "@val_num_asc"
    for (brick in z0) {
        base = 0
        for (x = x0[brick]; x <= x1[brick]; ++x) {
            for (y = y0[brick]; y <= y1[brick]; ++y) {
                if (base < height[x,y]) {
                    base = height[x,y]
                }
            }
        }
        if (DEBUG) {
            print "brick", brick, "sits atop", base
        }
        split("", supported[brick])
        top = z1[brick] - z0[brick] + base + 1
        for (x = x0[brick]; x <= x1[brick]; ++x) {
            for (y = y0[brick]; y <= y1[brick]; ++y) {
                if ((x SUBSEP y) in pile[base]) {
                    if (DEBUG) {
                        print "pile[" base "][" x "," y "] =", pile[base][x,y]
                    }
                    if (pile[base][x,y]) {
                        supported[brick][pile[base][x,y]] = 1
                    }
                }
                for (z = base + 1; z <= top; ++z) {
                    pile[z][x,y] = brick
                    bricks[brick][x,y,z] = brick
                }
                height[x,y] = top
            }
        }
    }
    PROCINFO["sorted_in"] = "@unsorted"
    for (brick in supported) {
        for (supporter in supported[brick]) {
            supporting[supporter][brick] = 1
            if (DEBUG) {
                print supporter, "supports", brick
            }
        }
    }
    for (brick = 1; brick <= NR; ++brick) {
        removable[brick] = 1
        if (brick in supporting) {
            for (b in supporting[brick]) {
                if (length(supported[b]) < 2) {
                    delete removable[brick]
                    break
                }
            }
        }
    }
    print length(removable)
}
