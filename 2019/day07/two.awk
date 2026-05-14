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
    START = 1
    NEED_INPUT = 2
    GAVE_OUTPUT = 3
    RUNNING = 4
    DONE = 5
    split("START NEED_INPUT GAVE_OUTPUT RUNNING DONE", STATES)
    STATUE[""] = "???"
    A = 1
    B = 2
    C = 3
    D = 4
    E = 5
    split("ABCDE", AMP_NAME, "")
    split("", PERMUTATIONS)
    find_permutations("", "56789")
    FS = ","
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
function parameter(amp, mode, value) {
    if (mode) {
        return value
    } else {
        return MEM[amp][value]
    }
}
function advance_program(amp,   pc, i1, i2, i3, x) {
    if (DEBUG > 1) {
        print AMP_NAME[amp], "advanced from state", STATES[STATE[amp]] > DFILE
    }
    if ((STATE[amp] == NEED_INPUT) && !(amp in INPUTS)) {
        aoc::compute_error(amp " needs input but started without any")
    }
    if (STATE[amp] >= RUNNING) {
        if (STATE[amp] == RUNNING) {
            aoc::compute_error(amp " already running when started")
        } else if (STATE[amp] == DONE) {
            aoc::compute_error(amp " already finished when started")
        } else {
            aoc::compute_error(amp " in unknown state when started")
        }
    }
    STATE[amp] = RUNNING

    pc = AMP_PC[amp]

    while ((pc in MEM[amp]) && (STATE[amp] == RUNNING)) {
        i1 = int(MEM[amp][pc] / 100) % 10
        i2 = int(MEM[amp][pc] / 1000) % 10
        i3 = int(MEM[amp][pc] / 10000) % 10
        if (DEBUG > 4) {
            printf "%s %04d: %05d %s", AMP_NAME[amp], pc, MEM[amp][pc], OPCODE[MEM[amp][pc] % 100] > DFILE
        }
        switch (MEM[amp][pc] % 100) {
        case 1:
            x = parameter(amp,i1, MEM[amp][pc+1]) + parameter(amp,i2, MEM[amp][pc+2])
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[amp][pc+1]), p(i2, MEM[amp][pc+2]), p(i3, MEM[amp][pc+3]), MEM[amp][pc+3], x > DFILE
            }
            MEM[amp][MEM[amp][pc+3]] = x
            pc += 4
            break
        case 2:
            x = parameter(amp,i1, MEM[amp][pc+1]) * parameter(amp,i2, MEM[amp][pc+2])
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[amp][pc+1]), p(i2, MEM[amp][pc+2]), p(i3, MEM[amp][pc+3]), MEM[amp][pc+3], x > DFILE
            }
            MEM[amp][MEM[amp][pc+3]] = x
            pc += 4
            break
        case 3:
            if (DEBUG > 4) {
                printf " %s : [%04d] = INPUT\n", p(i1, MEM[amp][pc+1]), MEM[amp][pc+1] > DFILE
            }
            if (amp in INPUTS) {
                MEM[amp][MEM[amp][pc+1]] = INPUTS[amp]
                delete INPUTS[amp]
                pc += 2
            } else {
                STATE[amp] = NEED_INPUT
            }
            break
        case 4:
            x = parameter(amp,i1, MEM[amp][pc+1])
            if (DEBUG > 4) {
                printf " %s : OUTPUT = %d\n", p(i1, MEM[amp][pc+1]), x > DFILE
            }
            if (DEBUG > 3) {
                print "->", AMP_NAME[amp], "gave output", x > DFILE
                print p(i1, MEM[amp][pc+1]), "=", parameter(amp,i1, MEM[amp][pc+1]) > DFILE
            }
            if (amp in OUTPUTS) {
                aoc::compute_error(amp " gave new output before prior output was taken")
            }
            OUTPUTS[amp] = x
            STATE[amp] = GAVE_OUTPUT
            pc += 2
            break
        case 5:
            x = parameter(amp,i1, MEM[amp][pc+1])
            y = parameter(amp,i2, MEM[amp][pc+2])
            if (DEBUG > 4) {
                printf " %s %s : ", p(i1, MEM[amp][pc+1]), p(i2, MEM[amp][pc+2]) > DFILE
            }
            if (x) {
                if (DEBUG > 4) {
                    printf "jump to %04d\n", y > DFILE
                }
                pc = y
            } else {
                if (DEBUG > 4) {
                    printf "not taken\n" > DFILE
                }
                pc += 3
            }
            break
        case 6:
            if (DEBUG > 4) {
                printf " %s %s : ", p(i1, MEM[amp][pc+1]), p(i2, MEM[amp][pc+2]) > DFILE
            }
            x = parameter(amp,i1, MEM[amp][pc + 1])
            y = parameter(amp,i2, MEM[amp][pc+2])
            if (x) {
                if (DEBUG > 4) {
                    printf "not taken\n" > DFILE
                }
                pc += 3
            } else {
                if (DEBUG > 4) {
                    printf "jump to %04d\n", y > DFILE
                }
                pc = y
            }
            break
        case 7:
            x = (parameter(amp,i1, MEM[amp][pc + 1]) < parameter(amp,i2, MEM[amp][pc + 2]))
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[amp][pc+1]), p(i2, MEM[amp][pc+2]), p(i3, MEM[amp][pc+3]), MEM[amp][pc+3], x > DFILE
            }
            MEM[amp][MEM[amp][pc+3]] = x
            pc += 4
            break
        case 8:
            x = (parameter(amp,i1, MEM[amp][pc + 1]) == parameter(amp,i2, MEM[amp][pc + 2]))
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d\n", p(i1, MEM[amp][pc+1]), p(i2, MEM[amp][pc+2]), p(i3, MEM[amp][pc+3]), MEM[amp][pc+3], x > DFILE
            }
            MEM[amp][MEM[amp][pc+3]] = x
            pc += 4
            break
        case 99:
            if (DEBUG > 4) {
                printf "\n" > DFILE
            }
            STATE[amp] = DONE
            break
        default:
            if (DEBUG > 4) {
                printf "\n" > DFILE
            }
            aoc::compute_error("illegal opcode " MEM[amp][pc])
        }
    }
    AMP_PC[amp] = pc
    if (DEBUG > 2) {
        print "", AMP_NAME[amp], "new state:", STATES[STATE[amp]] > DFILE
    }
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

    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (permutation in PERMUTATIONS) {
        if (DEBUG > 1) {
            print "trying permutation", permutation > DFILE
        }

        split(permutation, INPUTS, "")
        split("", OUTPUTS)
        for (amp = A; amp <= E; ++amp) {
            for (i = 0; i < NF; ++i) {
                MEM[amp][i] = PROG[i]
            }
            STATE[amp] = START
            AMP_PC[amp] = 0

            advance_program(amp)

            if (STATE[amp] != NEED_INPUT) {
                aoc::compute_error(amp " should be expecting input but is not")
            }
        }

        amp = A
        INPUTS[amp] = 0

        while (STATE[E] != DONE) {
            next_amp = (amp < E) ? (amp + 1) : A

            advance_program(amp)

            if (STATE[amp] == GAVE_OUTPUT) {
                if (next_amp in INPUTS) {
                    aoc::compute_error(amp " gave output to " next_amp " which already had input")
                }
                if (!(amp in OUTPUTS)) {
                    aoc::compute_error(amp " did not give output but reported that it did")
                }
                INPUTS[next_amp] = OUTPUTS[amp]
                if (amp == E) {
                    THRUSTER[permutation] = OUTPUTS[amp]
                }
                delete OUTPUTS[amp]
            }

            amp = next_amp
        }
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
