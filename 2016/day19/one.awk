#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    PROCINFO["sorted_in"] = "@ind_num_asc"
}
$0 !~ /^[[:digit:]]+$/ {
    aoc::data_error("expecting a number")
}
{
    for (e = 1; e <= $1; ++e) {
        ELF[e] = 1
    }
    taker = 0
    while (length(ELF) > 1) {
        if (DEBUG) print length(ELF), "elves remain" > DFILE
        for (e in ELF) {
            if (taker && (taker != e)) {
                ELF[taker] += ELF[e]
                delete ELF[e]
                taker = 0
            } else {
                taker = e
            }
        }
    }
    if (DEBUG) print "Remaining elf at end:" > DFILE
    for (e in ELF) {
        print e
    }
}
