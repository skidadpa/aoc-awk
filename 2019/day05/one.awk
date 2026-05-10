#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
    LAST_OUTPUT = "none"
}

$0 !~ /^-?[[:digit:]]+(,-?[[:digit:]]+)*$/ { aoc::data_error() }

function parameter(mode, value) {
    if (DEBUG > 5) {
        printf "parameter(%d,%d): %d\n", mode, value, mode ? value : MEM[value] > DFILE
    }
    if (mode) {
        return value
    } else {
        return MEM[value]
    }
}
function input() {
    return 1
}
function output(x) {
    LAST_OUTPUT = x
}

{
    split("", MEM)
    for (i = 1; i <= NF; ++i) {
        MEM[i - 1] = $i
    }
    if (DEBUG > 2) {
        print "MEMORY:" > DFILE
        for (i = 0; i < NF; ++i) {
            printf " %d: %d\n", i, MEM[i] > DFILE
        }
    }

    PC = 0

    while ((PC in MEM) && ((MEM[PC] % 100) > 0) && ((MEM[PC] % 100) < 5)) {
        i1 = int(MEM[PC] / 100) % 10
        i2 = int(MEM[PC] / 1000) % 10
        # i3 = int(MEM[PC] / 10000) % 10
        if (DEBUG) {
            printf "%d: %d\n", PC, MEM[PC] > DFILE
        }
        switch (MEM[PC] % 100) {
        case 1:
            result = parameter(i1, MEM[PC + 1]) + parameter(i2, MEM[PC + 2])
            if (DEBUG > 1) {
                print "writing", result, "to location", MEM[PC+3] > DFILE
            }
            MEM[MEM[PC + 3]] = result
            PC += 4
            break
        case 2:
            result = parameter(i1, MEM[PC + 1]) * parameter(i2, MEM[PC + 2])
            if (DEBUG > 1) {
                print "writing", result, "to location", MEM[PC+3] > DFILE
            }
            MEM[MEM[PC + 3]] = result
            PC += 4
            break
        case 3:
            if (DEBUG > 1) {
                print "writing input to location", MEM[PC+1] > DFILE
            }
            MEM[MEM[PC + 1]] = input()
            PC += 2
            break
        case 4:
            result = parameter(i1, MEM[PC + 1])
            if (DEBUG > 1) {
                print "outputting", result > DFILE
            }
            output(result)
            PC += 2
            break
        default:
            aoc::compute_error("illegal opcode " MEM[PC])
        }
    }
    if (DEBUG) {
        printf "END at PC = %d (%d)\n", PC, MEM[PC] > DFILE
    }
    if ((MEM[PC] % 100) != 99) {
        aoc::compute_error("did not end on opcode 99, ended on " MEM[PC] " instead")
    }
    print LAST_OUTPUT
}
