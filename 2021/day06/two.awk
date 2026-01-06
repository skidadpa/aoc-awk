#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NR == 1 && NF == 1) { split($1, fish, ","); for (i in fish) ++count[fish[i]] }
(NR != 1 || NF != 1) { aoc::data_error() }
END {
    for (day = 1; day <= 256; ++day) {
        for (i = 0; i <= 8; ++i) count[i-1] = count[i]
        count[6] += count[8] = count[-1]
    }
    for (i = 0; i <= 8; ++i) nfish += count[i]
    print nfish
}
