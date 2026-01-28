#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function power_level(x, y, serial_number) {
    return (int((((x + 10) * y + serial_number) * (x + 10)) / 100) % 10) - 5
}
BEGIN {
    DEBUG = 0
}
{
    if (DEBUG > 3) {
        print power_level(3,5,8) > DFILE
        print power_level(122,79,57) > DFILE
        print power_level(217,196,39) > DFILE
        print power_level(101,153,71) > DFILE
    }
    serial_number = $1
    for (x = 1; x <= 300; ++x) {
        rack_id = x + 10
        for (y = 1; y <= 300; ++y) {
            power = rack_id * y
            power += serial_number
            power *= rack_id
            CELL[x,y] = (int(power / 100) % 10) - 5
            GRID[x "," y] = CELL[x,y]
            if (x > 1) GRID[(x-1) "," y] += CELL[x,y]
            if (x > 2) GRID[(x-2) "," y] += CELL[x,y]
            if (y > 1) {
                GRID[x "," (y-1)] += CELL[x,y]
                if (x > 1) GRID[(x-1) "," (y-1)] += CELL[x,y]
                if (x > 2) GRID[(x-2) "," (y-1)] += CELL[x,y]
                if (y > 2) {
                    GRID[x "," (y-2)] += CELL[x,y]
                    if (x > 1) GRID[(x-1) "," (y-2)] += CELL[x,y]
                    if (x > 2) GRID[(x-2) "," (y-2)] += CELL[x,y]
                }
            }
        }
    }
    if (DEBUG > 10) {
        for (y = 1; y <= 300; ++y) {
            for (x = 1; x <= 300; ++x) {
                printf " % d", CELL[x,y] > DFILE
            }
            printf "\n" > DFILE
        }
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (coord in GRID) {
        if (DEBUG) {
            print "power", GRID[coord] > DFILE
        }
        print coord
        next
    }
    aoc::compute_error("no solution found")
}
