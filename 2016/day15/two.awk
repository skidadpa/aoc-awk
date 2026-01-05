#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
    LIMIT = 999999999
}
$0 !~ /^Disc #[[:digit:]]+ has [[:digit:]]+ positions; at time=0, it is at position [[:digit:]]+\.$/ {
    aoc::data_error()
}
{
    if ($2 < 2) {
        aoc::data_error("illegal disc size " $2)
    }
    SIZE[$1] = $2
    POSITION[$1] = ($4 + $1) % $2
    # Also should verify that all SIZES are relatively-prime
    if (DEBUG) {
        print > DFILE
    }
}
END {
    SIZE[NR + 1] = 11
    POSITION[NR + 1] = (NR + 1) % 11
    time = 0
    while (time <= LIMIT) {
        dt = 1
        disks_left = 0
        for (i in SIZE) {
            if (POSITION[i]) {
                ++disks_left
            } else {
                dt *= SIZE[i]
            }
        }
        if (!disks_left) {
            if (DEBUG) {
                print "found solution at time", time > DFILE
            }
            break
        }
        time += dt
        for (i in POSITION) {
            POSITION[i] = (POSITION[i] + dt) % SIZE[i]
        }
        if (DEBUG) {
            print disks_left, "disks left at time", time, "advancing time by", dt > DFILE
        }
    }
    if (disks_left) {
        aoc::compute_error("no solution found by time " LIMIT)
    }
    print time
}
