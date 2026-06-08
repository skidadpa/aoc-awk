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
    if (DEBUG > 19) {
        print "OPCODES:" > DFILE
        for (o in OPCODE) {
            printf " %02d %s\n", o, OPCODE[o] > DFILE
        }
    }
    for (ch = 1; ch < 128; ++ch) {
        ORD[sprintf("%c", ch)] = ch
    }
    DX["^"] = 0
    DY["^"] = -1
    DX["v"] = 0
    DY["v"] = 1
    DX[">"] = 1
    DY[">"] = 0
    DX["<"] = -1
    DY["<"] = 0
    BACKTRACK["^"] = "v"
    BACKTRACK["v"] = "^"
    BACKTRACK[">"] = "<"
    BACKTRACK["<"] = ">"
    ROTATIONS["^","^"] = ""
    ROTATIONS["^","v"] = "R,R,"
    ROTATIONS["^",">"] = "R,"
    ROTATIONS["^","<"] = "L,"
    ROTATIONS["v","^"] = "R,R,"
    ROTATIONS["v","v"] = ""
    ROTATIONS["v",">"] = "L,"
    ROTATIONS["v","<"] = "R,"
    ROTATIONS["<","^"] = "R,"
    ROTATIONS["<","v"] = "L,"
    ROTATIONS["<",">"] = "R,R,"
    ROTATIONS["<","<"] = ""
    ROTATIONS[">","^"] = "L,"
    ROTATIONS[">","v"] = "R,"
    ROTATIONS[">",">"] = ""
    ROTATIONS[">","<"] = "R,R,"
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
    if (DEBUG > 13) {
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
        if (DEBUG > 14) {
            printf "%04d: %05d %s", PC, m(PC), OPCODE[m(PC) % 100] > DFILE
        }
        switch (m(PC) % 100) {
        case 1: # ADD
            x = iparam(1) + iparam(2)
            if (DEBUG > 14) {
                printf " %s %s %s : [%04d] = %d + %d = %d\n", p(1), p(2), p(3), opos(3), iparam(1), iparam(2), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 2: # MUL
            x = iparam(1) * iparam(2)
            if (DEBUG > 14) {
                printf " %s %s %s : [%04d] = %d * %d = %d\n", p(1), p(2), p(3), opos(3), iparam(1), iparam(2), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 3: # INP
            if (DEBUG > 14) {
                printf " %s : [%04d] = INPUT", p(1), opos(1) > DFILE
            }
            if (INPUT_READY) {
                x = INPUT
                if (DYNAMIC_INPUT) {
                    INPUT_READY = 0
                }
                if (DEBUG > 14) {
                    printf " (%d)\n", x > DFILE
                }
                MEM[opos(1)] = x
                PC += 2
            } else {
                if (DEBUG > 14) {
                    printf " (pending)\n" > DFILE
                }
                STATE = NEED_INPUT
            }
            break
        case 4: # OUT
            x = iparam(1)
            if (DEBUG > 14) {
                printf " %s : OUTPUT = %d\n", p(1), x > DFILE
            }
            OUTPUT = x
            STATE = GAVE_OUTPUT
            PC += 2
            break
        case 5: # JNZ
            x = iparam(1)
            y = iparam(2)
            if (DEBUG > 14) {
                printf " %s %s", p(1), p(2) > DFILE
            }
            if (x) {
                if (DEBUG > 14) {
                    printf " (jump to %04d)\n", y > DFILE
                }
                PC = y
            } else {
                if (DEBUG > 14) {
                    printf " (not taken)\n" > DFILE
                }
                PC += 3
            }
            break
        case 6: # JZ
            if (DEBUG > 14) {
                printf " %s %s", p(1), p(2) > DFILE
            }
            x = iparam(1)
            y = iparam(2)
            if (x) {
                if (DEBUG > 14) {
                    printf " (not taken)\n" > DFILE
                }
                PC += 3
            } else {
                if (DEBUG > 14) {
                    printf " (jump to %04d)\n", y > DFILE
                }
                PC = y
            }
            break
        case 7: # LT
            x = (iparam(1) < iparam(2))
            if (DEBUG > 14) {
                printf " %s %s %s : [%04d] = %d\n", p(1), p(2), p(3), opos(3), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 8: # EQ
            x = (iparam(1) == iparam(2))
            if (DEBUG > 14) {
                printf " %s %s %s : [%04d] = %d\n", p(1), p(2), p(3), opos(3), x > DFILE
            }
            MEM[opos(3)] = x
            PC += 4
            break
        case 9: # STB
            x = iparam(1)
            if (DEBUG > 14) {
                printf " %s : RELATIVE_BASE = %d\n", p(1), RELATIVE_BASE + x > DFILE
            }
            RELATIVE_BASE += x
            PC += 2
            break
        case 99: # STP
            if (DEBUG > 14) {
                printf "\n" > DFILE
            }
            STATE = DONE
            break
        default:
            if (DEBUG > 14) {
                printf "\n" > DFILE
            }
            aoc::compute_error("illegal opcode " m(PC))
        }
    }
    if (DEBUG > 13) {
        print " new program state:", sSTATE[STATE] > DFILE
    }
}
function new_facing(x, y, facing,   FACINGS) {
    split("", FACINGS)
    if ((x SUBSEP (y-1)) in SCAFFOLD) {
        FACINGS["^"] = 1
    }
    if ((x SUBSEP (y+1)) in SCAFFOLD) {
        FACINGS["v"] = 1
    }
    if (((x-1) SUBSEP y) in SCAFFOLD) {
        FACINGS["<"] = 1
    }
    if (((x+1) SUBSEP y) in SCAFFOLD) {
        FACINGS[">"] = 1
    }
    if ((facing in BACKTRACK) && (BACKTRACK[facing] in FACINGS)) {
        delete FACINGS[BACKTRACK[facing]]
    }
    if (length(FACINGS) > 1) {
        aoc::compute_error("[" x "," y "] not at end or expected corner")
    }
    for (facing in FACINGS) {
        return facing
    }
    return "END"
}
function num_matches(str, s,   cnt, m) {
    cnt = 0
    while (m = match(str, s)) {
        ++cnt
        str = substr(str, m + length(s))
    }
    return cnt
}
function replacement_function(replacement,   start, best_match, moved, len, s, m1) {
    start = match(PATH, /[LR]/)
    if (start < 1) {
        return ""
    }
    best_match = ""
    moved = 0
    for (len = 1; len <= (length(PATH) - start); ++len) {
        switch (substr(PATH, start + len - 1, 1)) {
        case "A":
        case "B":
        case "C":
            # no nested functions allowed
            len = length(PATH)
            break
        case "L":
        case "R":
            moved = 0
            break
        case ",":
            if (moved) {
                # search after move ops
                s = substr(PATH,start,len - 1)
                if (num_matches(PATH, s) > 2) {
                    best_match = s
                }
            }
            break
        default:
            moved = 1
            break
        }
    }
    gsub(best_match, replacement, PATH)
    return best_match
}
{
    split("", MEM)
    for (i = 1; i <= NF; ++i) {
        MEM[i-1] = $i
    }
    MEM[0] = 2
    if (DEBUG > 19) {
        print "PROGRAM:" > DFILE
        for (i = 0; i < NF; ++i) {
            printf " %d: %d\n", i, MEM[i] > DFILE
        }
    }

    STATE = START
    PC = 0
    RELATIVE_BASE = 0
    INPUT = 0
    INPUT_READY = 0
    DYNAMIC_INPUT = 1

    INITIAL_FACING = ROBOTX = ROBOTY = ""
    split("", VIEW)
    x = 0
    y = 0
    input_data = ""
    mapping = 1
    computing = 0
    querying = 0
    reporting = 0
    errored = 0
    RESULT = ""
    while (1) {
        advance_program()
        if (STATE == DONE) {
            break
        } else if (querying && (STATE == NEED_INPUT)) {
            if (length(input_data) > 0) {
                INPUT = ORD[substr(input_data, 1, 1)]
                input_data = substr(input_data, 2)
            } else {
                INPUT = ORD["\n"]
                if (last_query == "Continuous video feed?") {
                    querying = 0
                    reporting = 1
                }
            }
            if (DEBUG) {
                printf "%c", INPUT > DFILE
                fflush(DFILE)
            }
            INPUT_READY = 1
            continue
            next
        } else if (STATE != GAVE_OUTPUT) {
            aoc::compute_error("STATE is " sSTATE[STATE] " instead of GAVE_OUTPUT")
        }
        out = sprintf("%c", OUTPUT)
        if (mapping) {
            switch (out) {
            case "#":
                SCAFFOLD[x,y] = 1
                break
            case ".":
            case "\n":
                break
            case "^":
            case "v":
            case "<":
            case ">":
                if ("" INITIAL_FACING ROBOTX ROBOTY != "") {
                    aoc::compute_error("saw second robot")
                }
                SCAFFOLD[x,y] = 1
                INITIAL_FACING = out
                ROBOTX = x
                ROBOTY = y
                break
            case "M":
                mapping = 0
                computing = 1
                break
            default:
                mapping = 0
                errored = 1
                break
            }
            if (out == "\n") {
                ++y
                x = 0
            } else {
                VIEW[x++,y] = out
            }
        }
        if (computing) {
            x = ROBOTX
            y = ROBOTY
            facing = new_facing(x, y, "")
            PATH = ROTATIONS[INITIAL_FACING,facing]
            while (facing != "END") {
                distance = 0
                while (((x + DX[facing]) SUBSEP (y + DY[facing])) in SCAFFOLD) {
                    x += DX[facing]
                    y += DY[facing]
                    ++distance
                }
                PATH = PATH distance
                next_facing = new_facing(x, y, facing)
                if (next_facing != "END") {
                    PATH = PATH "," ROTATIONS[facing, next_facing]
                }
                facing = next_facing
            }

            if (DEBUG > 1) {
                print "DESIRED PATH:", PATH > DFILE
            }

            # if (PATH != "R,10,R,10,R,6,R,4,R,10,R,10,L,4,R,10,R,10,R,6,R,4,R,4,L,4,L,10,L,10,R,10,R,10,R,6,R,4,R,10,R,10,L,4,R,4,L,4,L,10,L,10,R,10,R,10,L,4,R,4,L,4,L,10,L,10,R,10,R,10,L,4") {
            #     aoc::compute_error("current solution is hardwired only")
            # }
            # RESPONSES["Main:"] = "A,B,A,C,A,B,C,B,C,B"
            # RESPONSES["Function A:"] = "R,10,R,10,R,6,R,4"
            # RESPONSES["Function B:"] = "R,10,R,10,L,4"
            # RESPONSES["Function C:"] = "R,4,L,4,L,10,L,10"

            RESPONSES["Function A:"] = replacement_function("A")
            RESPONSES["Function B:"] = replacement_function("B")
            RESPONSES["Function C:"] = replacement_function("C")
            RESPONSES["Main:"] = PATH
            RESPONSES["Continuous video feed?"] = (DEBUG > 9) ? "y" : "n"

            if (DEBUG > 1) {
                for (r in RESPONSES) {
                    printf "RESPONSES[%s] = %s\n", r, RESPONSES[r] > DFILE
                }
            }
            computing = 0
            querying = 1
            query = ""
            last_query = ""
        }
        if (querying) {
            switch (out) {
            case "#":
            case ".":
            case "^":
            case "<":
            case ">":
            case "X":
                aoc::compute_error("expecting query, got map character " out)
            case "M":
            case "A":
            case "B":
            case "C":
            case "?":
            case "a":
            case "i":
            case "n":
            case ":":
            case " ":
            case "F":
            case "u":
            case "c":
            case "t":
            case "o":
            case "s":
            case "v":
            case "d":
            case "e":
            case "f":
                query = query out
                break
            case "\n":
                if (query in RESPONSES) {
                    input_data = RESPONSES[query]
                } else {
                    aoc::compute_error("no response for " query)
                }
                last_query = query
                query = ""
                break
            default:
                querying = 0
                errored = 1
                break
            }
        }
        if (reporting) {
            switch (out) {
            case "#":
            case ".":
            case "\n":
            case "^":
            case "v":
            case "<":
            case ">":
                break
            default:
                if (OUTPUT >= 128) {
                    if (DEBUG) {
                        print "GOT RESULT:", OUTPUT
                    }
                    if (RESULT != "") {
                        aoc::compute_error("got duplicate result: " OUTPUT)
                    }
                    RESULT = OUTPUT
                    out = ""
                } else {
                    reporting = 0
                    errored = 1
                }
                break
            }
        }
        if (DEBUG) {
            printf "%s", out > DFILE
        }
    }

    if (errored) {
        aoc::compute_error("got unexpected error output")
    }

    if (RESULT == "") {
        aoc::compute_error("did not get a result")
    }
    print RESULT
}
