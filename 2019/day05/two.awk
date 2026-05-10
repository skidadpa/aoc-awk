#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("ADD MUL INP OUT JNZ JZ LT CMP", OPCODE)
    OPCODE[99] = "HCF"
    OPCODE[""] = "???"
    FS = ","
    LAST_OUTPUT = "none"
    if (DEBUG > 14) {
        print "OPCODES:" > DFILE
        for (o in OPCODE) {
            printf " %02d %s\n", o, OPCODE[o] > DFILE
        }
    }
}

$0 !~ /^-?[[:digit:]]+(,-?[[:digit:]]+)*$/ { aoc::data_error() }

function p(mode, value) {
    if (mode) {
        return "#" value
    } else {
        return "[" value "]"
    }
}
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
    return 5
}
function output(x) {
    LAST_OUTPUT = x
}

{
    split("", MEM)
    for (i = 1; i <= NF; ++i) {
        MEM[i - 1] = $i
    }
    if (DEBUG > 9) {
        print "MEMORY:" > DFILE
        for (i = 0; i < NF; ++i) {
            printf " %d: %d\n", i, MEM[i] > DFILE
        }
    }

    PC = 0

    while ((PC in MEM) && ((MEM[PC] % 100) > 0) && ((MEM[PC] % 100) < 9)) {
        i1 = int(MEM[PC] / 100) % 10
        i2 = int(MEM[PC] / 1000) % 10
        i3 = int(MEM[PC] / 10000) % 10
        if (DEBUG) {
            printf "%04d: %05d %s", PC, MEM[PC], OPCODE[MEM[PC] % 100] > DFILE
        }
        switch (MEM[PC] % 100) {
        case 1:
            x = parameter(i1, MEM[PC+1]) + parameter(i2, MEM[PC+2])
            if (DEBUG) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
            }
            MEM[MEM[PC+3]] = x
            PC += 4
            break
        case 2:
            x = parameter(i1, MEM[PC+1]) * parameter(i2, MEM[PC+2])
            if (DEBUG) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
            }
            MEM[MEM[PC+3]] = x
            PC += 4
            break
        case 3:
            if (DEBUG) {
                printf " %s : [%04d] = INPUT\n", p(i1, MEM[PC+1]), MEM[PC+1] > DFILE
            }
            MEM[MEM[PC+1]] = input()
            PC += 2
            break
        case 4:
            x = parameter(i1, MEM[PC+1])
            if (DEBUG) {
                printf " %s : OUTPUT = %d\n", p(i1, MEM[PC+1]), x > DFILE
            }
            output(x)
            PC += 2
            break
        case 5:
            x = parameter(i1, MEM[PC+1])
            y = parameter(i2, MEM[PC+2])
            if (DEBUG) {
                printf " %s %s : ", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]) > DFILE
            }
            if (x) {
                if (DEBUG) {
                    printf "jump to %04d\n", y > DFILE
                }
                PC = y
            } else {
                if (DEBUG) {
                    printf "not taken\n" > DFILE
                }
                PC += 3
            }
            break
        case 6:
            if (DEBUG) {
                printf " %s %s : ", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]) > DFILE
            }
            x = parameter(i1, MEM[PC + 1])
            y = parameter(i2, MEM[PC+2])
            if (x) {
                if (DEBUG) {
                    printf "not taken\n" > DFILE
                }
                PC += 3
            } else {
                if (DEBUG) {
                    printf "jump to %04d\n", y > DFILE
                }
                PC = y
            }
            break
        case 7:
            x = (parameter(i1, MEM[PC + 1]) < parameter(i2, MEM[PC + 2]))
            if (DEBUG) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
            }
            MEM[MEM[PC+3]] = x
            PC += 4
            break
        case 8:
            x = (parameter(i1, MEM[PC + 1]) == parameter(i2, MEM[PC + 2]))
            if (DEBUG) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
            }
            MEM[MEM[PC+3]] = x
            PC += 4
            break
        default:
            if (DEBUG) {
                printf "\n" > DFILE
            }
            aoc::compute_error("illegal opcode " MEM[PC])
        }
    }
    if (DEBUG) {
        printf "END: %d: %s\n", PC, OPCODE[(PC in MEM) ? (MEM[PC] % 100) : ""] > DFILE
    }
    if ((MEM[PC] % 100) != 99) {
        aoc::compute_error("did not end on opcode 99, ended on " MEM[PC] " instead")
    }
    print LAST_OUTPUT
}
