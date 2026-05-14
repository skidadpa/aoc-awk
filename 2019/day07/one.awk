#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function find_permutations(base, options,   i, new_options) {
    if (length(options) == 1) {
        PERMUTATIONS[base options] = 1
    } else {
        for (i = 1; i <= length(options); ++i) {
            if (i > 1) {
                new_options = substr(options, 1, i - 1)
            } else {
                new_options = ""
            }
            if (i < length(options)) {
                new_options = new_options substr(options, i+1)
            }
            find_permutations(base substr(options, i, 1), new_options)
        }
    }
}
BEGIN {
    split("ADD MUL INP OUT JNZ JZ LT CMP", OPCODE)
    OPCODE[99] = "HCF"
    OPCODE[""] = "???"
    FS = ","
    LAST_OUTPUT = "none"
    A = 1
    B = 2
    C = 3
    D = 4
    E = 5
    AMP_NAME[A] = "A"
    AMP_NAME[B] = "B"
    AMP_NAME[C] = "C"
    AMP_NAME[D] = "D"
    AMP_NAME[E] = "E"
    split("", PERMUTATIONS)
    find_permutations("", "01234")
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
    if (mode) {
        return value
    } else {
        return MEM[value]
    }
}
function input() {
    return INPUTS[CURRENT_INPUT++]
}
function output(x) {
    LAST_OUTPUT = x
}

{
    split("", PROG)
    for (i = 1; i <= NF; ++i) {
        PROG[i - 1] = $i
    }
    if (DEBUG > 14) {
        print "PROGRAM:" > DFILE
        for (i = 0; i < NF; ++i) {
            printf " %d: %d\n", i, PROG[i] > DFILE
        }
    }

    split("", TRIED)
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (permutation in PERMUTATIONS) {
        if (DEBUG > 1) {
            print "trying permutation", permutation > DFILE
        }
        LAST_OUTPUT = 0
        for (amp = A; amp <= E; ++amp) {
            phase = substr(permutation, amp, 1)
            INPUT = phase SUBSEP LAST_OUTPUT
            if (DEBUG > 2) {
                print "amplifier", AMP_NAME[amp], "phase", phase, "input", LAST_OUTPUT > DFILE
            }
            if (INPUT in TRIED) {
                LAST_OUTPUT = TRIED[INPUT]
            } else {
                split(INPUT, INPUTS, SUBSEP)
                CURRENT_INPUT = 1
                LAST_OUTPUT = "none"

                split("", MEM)
                for (i = 0; i < NF; ++i) {
                    MEM[i] = PROG[i]
                }
                PC = 0

                while ((PC in MEM) && ((MEM[PC] % 100) > 0) && ((MEM[PC] % 100) < 9)) {
                    i1 = int(MEM[PC] / 100) % 10
                    i2 = int(MEM[PC] / 1000) % 10
                    i3 = int(MEM[PC] / 10000) % 10
                    if (DEBUG > 4) {
                        printf "%04d: %05d %s", PC, MEM[PC], OPCODE[MEM[PC] % 100] > DFILE
                    }
                    switch (MEM[PC] % 100) {
                    case 1:
                        x = parameter(i1, MEM[PC+1]) + parameter(i2, MEM[PC+2])
                        if (DEBUG > 4) {
                            printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
                        }
                        MEM[MEM[PC+3]] = x
                        PC += 4
                        break
                    case 2:
                        x = parameter(i1, MEM[PC+1]) * parameter(i2, MEM[PC+2])
                        if (DEBUG > 4) {
                            printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
                        }
                        MEM[MEM[PC+3]] = x
                        PC += 4
                        break
                    case 3:
                        if (DEBUG > 4) {
                            printf " %s : [%04d] = INPUT\n", p(i1, MEM[PC+1]), MEM[PC+1] > DFILE
                        }
                        MEM[MEM[PC+1]] = input()
                        PC += 2
                        break
                    case 4:
                        x = parameter(i1, MEM[PC+1])
                        if (DEBUG > 4) {
                            printf " %s : OUTPUT = %d\n", p(i1, MEM[PC+1]), x > DFILE
                        }
                        output(x)
                        PC += 2
                        break
                    case 5:
                        x = parameter(i1, MEM[PC+1])
                        y = parameter(i2, MEM[PC+2])
                        if (DEBUG > 4) {
                            printf " %s %s : ", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]) > DFILE
                        }
                        if (x) {
                            if (DEBUG > 4) {
                                printf "jump to %04d\n", y > DFILE
                            }
                            PC = y
                        } else {
                            if (DEBUG > 4) {
                                printf "not taken\n" > DFILE
                            }
                            PC += 3
                        }
                        break
                    case 6:
                        if (DEBUG > 4) {
                            printf " %s %s : ", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]) > DFILE
                        }
                        x = parameter(i1, MEM[PC + 1])
                        y = parameter(i2, MEM[PC+2])
                        if (x) {
                            if (DEBUG > 4) {
                                printf "not taken\n" > DFILE
                            }
                            PC += 3
                        } else {
                            if (DEBUG > 4) {
                                printf "jump to %04d\n", y > DFILE
                            }
                            PC = y
                        }
                        break
                    case 7:
                        x = (parameter(i1, MEM[PC + 1]) < parameter(i2, MEM[PC + 2]))
                        if (DEBUG > 4) {
                            printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
                        }
                        MEM[MEM[PC+3]] = x
                        PC += 4
                        break
                    case 8:
                        x = (parameter(i1, MEM[PC + 1]) == parameter(i2, MEM[PC + 2]))
                        if (DEBUG > 4) {
                            printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[PC+1]), p(i2, MEM[PC+2]), p(i3, MEM[PC+3]), MEM[PC+3], x > DFILE
                        }
                        MEM[MEM[PC+3]] = x
                        PC += 4
                        break
                    default:
                        if (DEBUG > 4) {
                            printf "\n" > DFILE
                        }
                        aoc::compute_error("illegal opcode " MEM[PC])
                    }
                }
                if (DEBUG > 4) {
                    printf "END: %d: %s\n", PC, OPCODE[(PC in MEM) ? (MEM[PC] % 100) : ""] > DFILE
                }
                if ((MEM[PC] % 100) != 99) {
                    aoc::compute_error("did not end on opcode 99, ended on " MEM[PC] " instead")
                }
                TRIED[INPUT] = LAST_OUTPUT
            }
        }
        THRUSTER[permutation] = LAST_OUTPUT
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (permutation in THRUSTER) {
        if (DEBUG) {
            print "best permutation:", permutation > DFILE
        }
        print THRUSTER[permutation]
        break
    }
}
