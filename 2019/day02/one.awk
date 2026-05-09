#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
}

$0 !~ /^[[:digit:]]+(,[[:digit:]]+)*$/ { aoc::data_error() }

{
    split("", MEM)
    for (i = 1; i <= NF; ++i) {
        MEM[i - 1] = $i
    }

    PC = 0

    MEM[1] = 12
    MEM[2] = 2
    while ((PC in MEM) && (MEM[PC] > 0) && (MEM[PC] < 3)) {
        switch (MEM[PC]) {
        case 1:
            result = MEM[MEM[PC + 1]] + MEM[MEM[PC + 2]]
            break
        case 2:
            result = MEM[MEM[PC + 1]] * MEM[MEM[PC + 2]]
            break
        default:
            aoc::compute_error("illegal opcode " MEM[PC])
        }
        MEM[MEM[PC + 3]] = result
        PC += 4
    }
    if (MEM[PC] != 99) {
        aoc::compute_error("did not end on opcode 99, ended on " MEM[PC] " instead")
    }
    print MEM[0]
}
