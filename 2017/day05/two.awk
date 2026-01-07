#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
($0 !~ /^-?[[:digit:]]+$/) {
    aoc::data_error()
}
{
    JUMPS[NR] = int($1)
}
END {
    for (pc = 1; pc in JUMPS; pc = next_pc) {
        if (DEBUG) {
            for (i in JUMPS) {
                if (i == pc) {
                    printf("(%3d)", JUMPS[i]) > DFILE
                } else {
                    printf(" %3d ", JUMPS[i]) > DFILE
                }
            }
            printf("\n") > DFILE
        }
        next_pc = pc + JUMPS[pc]
        if (JUMPS[pc] < 3) {
            ++JUMPS[pc]
        } else {
            --JUMPS[pc]
        }
        ++instruction_count
    }
    if (DEBUG) {
        for (i in JUMPS) {
            printf(" %3d ", JUMPS[i]) > DFILE
        }
        printf("\n") > DFILE
    }
    print instruction_count
}
