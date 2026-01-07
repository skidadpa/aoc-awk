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
        next_pc = pc + JUMPS[pc]
        ++JUMPS[pc]
        ++instruction_count
    }
    print instruction_count
}
