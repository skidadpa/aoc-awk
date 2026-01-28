#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
{
    serial_number = $1
    for (x = 0; x <= 300; ++x) {
        SUM[x,0] = SUM[0,x] = 0
    }
    for (x = 1; x <= 300; ++x) {
        rack_id = x + 10
        for (y = 1; y <= 300; ++y) {
            power = rack_id * y
            power += serial_number
            power *= rack_id
            power = (int(power / 100) % 10) - 5
            CELL[x,y] = power
            SUM[x,y] = power + SUM[x-1,y] + SUM[x,y-1] - SUM[x-1,y-1]
        }
    }
    for (s = 1; s <= 300; ++s) {
        for (x = 0; x <= (300 - s); ++x) {
            for (y = 0; y <= (300 - s); ++y) {
                GRID[(x + 1) "," (y + 1) "," s] = SUM[x,y] + SUM[x+s,y+s] - SUM[x+s,y] - SUM[x,y+s]
            }
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
