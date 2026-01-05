#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    PROCINFO["sorted_in"] = "@val_num_asc"
    FPAT = "[[:digit:]]+"
}
(NF != 2) {
    aoc::data_error()
}
{
    if ($1 in BLOCKED) {
        aoc::data_error("duplicate start in " BLOCKED[$1] " " $2)
    }
    BLOCKED[$1] = $2
}
END {
    ip = 0
    for (b in BLOCKED) {
        if (int(b) <= ip) {
            if (DEBUG) {
                printf ("%010d in [%010d:%010d]\n", ip, b, BLOCKED[b]) > DFILE
            }
            ip = BLOCKED[b] + 1
        }
    }
    print ip
}
