#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
}

$0 !~ /^[[:digit:]]+(,[[:digit:]]+)*$/ { aoc::data_error() }

{
    for (noun = 0; noun <= 99; ++noun) {
        for (verb = 0; verb <= 99; ++verb) {
            split("", MEM)
            for (i = 1; i <= NF; ++i) {
                MEM[i - 1] = $i
            }
            MEM[1] = noun
            MEM[2] = verb

            PC = 0

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
                continue
            }
            if (MEM[0] == 19690720) {
                print noun * 100 + verb
                next
            }
        }
    }
    aoc::compute_error("no solution found")
}
