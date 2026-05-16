#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    ADD = 1
    MUL = 2
    INP = 3
    OUT = 4
    JNZ = 5
    JZ = 6
    LT = 7
    EQ = 8
    STB = 9
    STP = 99
    split("ADD MUL INP OUT JNZ JZ LT EQ STB", OPCODE)
    OPCODE[99] = "STP"
    OPCODE[""] = "???"
    START = 1
    NEED_INPUT = 2
    GAVE_OUTPUT = 3
    RUNNING = 4
    DONE = 5
    split("START NEED_INPUT GAVE_OUTPUT RUNNING DONE", sSTATE)
    sSTATE[""] = "???"
    MODE_POS[1] = 100
    MODE_POS[2] = 1000
    MODE_POS[3] = 10000
    FS = ","
    if (DEBUG > 14) {
        print "OPCODES:" > DFILE
        for (o in OPCODE) {
            printf " %02d %s\n", o, OPCODE[o] > DFILE
        }
    }
}

$0 !~ /^-?[[:digit:]]+(,-?[[:digit:]]+)*$/ { aoc::data_error() }

function m(address) {
    if (!(address in MEM)) {
        MEM[address] = 0
    }
    return MEM[address]
}
function p(pos,   value) {
    value = m(PC+pos)
    switch (MODE[pos]) {
    case 0:
        return "[" value "]"
    case 1:
        return "#" value
    case 2:
        return "REL[" value "]"
    default:
        aoc::compute_error("unknown mode " MODE[pos])
    }
}
function iparam(pos,   value) {
    value = m(PC+pos)
    switch (MODE[pos]) {
    case 0:
        return m(value)
    case 1:
        return value
    case 2:
        return m(RELATIVE_BASE+value)
    default:
        aoc::compute_error("unknown mode " MODE[pos])
    }
}
function opos(pos,   value) {
    value = m(PC+pos)
    switch (MODE[pos]) {
    case 0:
        return value
    case 1:
        aoc::compute_error("output param cannot be in immediate mode")
    case 2:
        return RELATIVE_BASE+value
    default:
        aoc::compute_error("unknown mode " MODE[pos])
    }
}
function advance_program(   i1, i2, i3, x, y) {
    if (DEBUG > 1) {
        print "program advanced from state", sSTATE[STATE] > DFILE
    }
    if ((STATE == NEED_INPUT) && !(INPUT_READY)) {
        aoc::compute_error("program needs input but started without any")
    }
    if (STATE >= RUNNING) {
        if (STATE == RUNNING) {
            aoc::compute_error("program already running when started")
        } else if (STATE == DONE) {
            aoc::compute_error("program already finished when started")
        } else {
            aoc::compute_error("program in unknown state when started")
        }
    }
    STATE = RUNNING

    while (STATE == RUNNING) {
        for (i = 1; i <= 3; ++i) {
            MODE[i] = int(m(PC)/MODE_POS[i]) % 10
        }
        i1 = int(m(PC)/100) % 10
        i2 = int(m(PC)/1000) % 10
        i3 = int(m(PC)/10000) % 10
        if (DEBUG > 4) {
            printf "%04d: %05d %s", PC, m(PC), OPCODE[m(PC) % 100] > DFILE
        }
        switch (m(PC) % 100) {
        case 1: # ADD
            x = iparam(1) + iparam(2)
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d + %d = %d\n", p(1), p(2), p(3), opos(3), iparam(1), iparam(2), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 2: # MUL
            x = iparam(1) * iparam(2)
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d * %d = %d\n", p(1), p(2), p(3), opos(3), iparam(1), iparam(2), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 3: # INP
            if (DEBUG > 4) {
                printf " %s : [%04d] = INPUT", p(1), opos(1) > DFILE
            }
            if (INPUT_READY) {
                x = INPUT
                if (DYNAMIC_INPUT) {
                    INPUT_READY = 0
                }
                if (DEBUG > 4) {
                    printf " (%d)\n", x > DFILE
                }
                MEM[opos(1)] = x
                PC += 2
            } else {
                if (DEBUG > 4) {
                    printf " (pending)\n" > DFILE
                }
                STATE = NEED_INPUT
            }
            break
        case 4: # OUT
            x = iparam(1)
            if (DEBUG > 4) {
                printf " %s : OUTPUT = %d\n", p(1), x > DFILE
            }
            OUTPUT = x
            STATE = GAVE_OUTPUT
            PC += 2
            break
        case 5: # JNZ
            x = iparam(1)
            y = iparam(2)
            if (DEBUG > 4) {
                printf " %s %s", p(1), p(2) > DFILE
            }
            if (x) {
                if (DEBUG > 4) {
                    printf " (jump to %04d)\n", y > DFILE
                }
                PC = y
            } else {
                if (DEBUG > 4) {
                    printf " (not taken)\n" > DFILE
                }
                PC += 3
            }
            break
        case 6: # JZ
            if (DEBUG > 4) {
                printf " %s %s", p(1), p(2) > DFILE
            }
            x = iparam(1)
            y = iparam(2)
            if (x) {
                if (DEBUG > 4) {
                    printf " (not taken)\n" > DFILE
                }
                PC += 3
            } else {
                if (DEBUG > 4) {
                    printf " (jump to %04d)\n", y > DFILE
                }
                PC = y
            }
            break
        case 7: # LT
            x = (iparam(1) < iparam(2))
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d\n", p(1), p(2), p(3), opos(3), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 8: # EQ
            x = (iparam(1) == iparam(2))
            if (DEBUG > 4) {
                printf " %s %s %s : [%04d] = %d\n", p(1), p(2), p(3), opos(3), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 9: # STB
            x = iparam(1)
            if (DEBUG > 4) {
                printf " %s : RELATIVE_BASE = %d\n", p(1), RELATIVE_BASE + x > DFILE
            }
            RELATIVE_BASE += x
            PC += 2
            break
        case 99: # STP
            if (DEBUG > 4) {
                printf "\n" > DFILE
            }
            STATE = DONE
            break
        default:
            if (DEBUG > 4) {
                printf "\n" > DFILE
            }
            aoc::compute_error("illegal opcode " m(PC))
        }
    }
    if (DEBUG > 2) {
        print " new program state:", sSTATE[STATE] > DFILE
    }
}

{
    split("", MEM)
    for (i = 1; i <= NF; ++i) {
        MEM[i-1] = $i
    }
    if (DEBUG > 14) {
        print "PROGRAM:" > DFILE
        for (i = 0; i < NF; ++i) {
            printf " %d: %d\n", i, MEM[i] > DFILE
        }
    }

    STATE = START
    PC = 0
    RELATIVE_BASE = 0
    SEP = ""
    INPUT = 1
    INPUT_READY = 1
    DYNAMIC_INPUT = 0

    while (STATE != DONE) {
        advance_program()
        if (STATE == NEED_INPUT) {
            INPUT_READY = 1
            if (DEBUG) {
                print "PROVIDED INPUT", INPUT > DFILE
            }
        }
        if (STATE == GAVE_OUTPUT) {
            printf "%s%d", SEP, OUTPUT
            SEP = ","
            if (DEBUG) {
                printf "\n" > DFILE
                print "GAVE OUTPUT", OUTPUT > DFILE
            }
        }
    }
    printf "\n"
}
