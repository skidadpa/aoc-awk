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
    REPORT_X = 1
    REPORT_Y = 2
    REPORT_TILE = 3
    REPORT_ZERO = 4
    REPORT_SCORE = 5
    split("REPORT_X REPORT_Y REPORT_TILE REPORT_ZERO REPORT_SCORE", TASKS)
    EMPTY = 0
    WALL = 1
    BLOCK = 2
    PADDLE = 3
    BALL = 4
    split("WALL BLOCK PADDLE BALL", TILES)
    TILES[0] = "EMPTY"
    FS = ","
    SCORE_DRAWN = 0
    SLOW_DISPLAY = 0
    PAUSE_FOR_REFRESH = 0
    PAUSING = 0
    NOT_PAUSING = 0
    HUMAN_INPUT = 0
    VIDEO = 0
    DEBUG = 0
    DFILE = "debug.out"
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
    if (DEBUG > 3) {
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
    if (DEBUG > 3) {
        print " new program state:", sSTATE[STATE] > DFILE
    }
}
function refresh_screen(pausing,   y, x, pos) {
    aoc::home_cursor()
    aoc::clear_eol()
    printf "Ball: [%d,%d] <%d,%d>\n", XBALL, YBALL, VXBALL, VYBALL
    aoc::clear_eol()
    printf "Paddle: [%d,%d] <%d>\n", XPADDLE, YPADDLE, XDEST
    aoc::clear_eol()
    print "Score:", SCORE
    for (y = YMIN; y <= YMAX; ++y) {
        for (x = XMIN; x <= XMAX; ++x) {
            pos = (x SUBSEP y)
            if (pos in WALLS) {
                printf "#"
            } else if (pos in BLOCKS) {
                printf "X"
            } else if (pos in PADDLES) {
                printf "="
            } else if (pos in BALLS) {
                printf "o"
            } else {
                printf " "
            }
        }
        printf "\n"
    }
    if (pausing) {
        aoc::clear_eol()
        printf "[hit return]"
        if ((getline pausing < "-") < 0) {
            STATE = DONE
        }
        printf "\r"
    }
    aoc::clear_eol()
    if (SCORE_DRAWN && SLOW_DISPLAY) {
        system("sleep 0.005")
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
    INPUT = 0
    INPUT_READY = 0
    DYNAMIC_INPUT = 1
    TASK = REPORT_X
    split("", WALLS)
    split("", BLOCKS)
    split("", PADDLES)
    split("", WALLS)
    XMIN = XMAX = YMIN = YMAX = SCORE = "unknown"
    if (VIDEO) {
        aoc::clear_screen()
    }
    MEM[0] = 2
    XBALL = YBALL = XBALLPREV = YBALLPREV = VXBALL = VYBALL = 0
    XDEST = XPADDLE = YPADDLE = 0

    while (STATE != DONE) {
        advance_program()
        if (STATE == NEED_INPUT) {
            if (VIDEO) {
                refresh_screen(NOT_PAUSING)
            }
            move_paddle = XDEST - XPADDLE
            if (HUMAN_INPUT) {
                printf "input (-1,0,1): "
                if ((getline move_paddle < "-") < 0) {
                    STATE = DONE
                }
            }
            if (move_paddle < 0) {
                INPUT = -1
            } else if (move_paddle > 0) {
                INPUT = 1
            } else {
                INPUT = 0
            }
            INPUT = move_paddle
            INPUT_READY = 1
        } else if (STATE == GAVE_OUTPUT) {
            switch (TASK) {
            case 1: # REPORT_X
                if (OUTPUT == -1) {
                    TASK = REPORT_ZERO
                } else {
                    X = OUTPUT
                    if (XMIN == "unknown") {
                        XMIN = XMAX = X
                    }
                    XMIN = aoc::min(XMIN, X)
                    XMAX = aoc::max(XMAX, X)
                    TASK = REPORT_Y
                }
                break
            case 2: # REPORT_Y
                Y = OUTPUT
                if (YMIN == "unknown") {
                    YMIN = YMAX = Y
                }
                YMIN = aoc::min(YMIN, Y)
                YMAX = aoc::max(YMAX, Y)
                TASK = REPORT_TILE
                break
            case 3: # REPORT_TILE
                pos = (X SUBSEP Y)
                switch (OUTPUT) {
                case 0: # EMPTY
                    if (pos in WALLS) {
                        delete WALLS[pos]
                    }
                    if (pos in BLOCKS) {
                        if (DEBUG) {
                            printf "KILLED BLOCK [%d,%d] from [%d,%d] <%d,%d>\n", X, Y, XBALL, YBALL, VXBALL, VYBALL > DFILE
                        }
                        delete BLOCKS[pos]
                    }
                    if (pos in PADDLES) {
                        delete PADDLES[pos]
                    }
                    if (pos in BALLS) {
                        delete BALLS[pos]
                    }
                    break
                case 1: # WALL
                    WALLS[pos] = 1
                    if (pos in BLOCKS) {
                        delete BLOCKS[pos]
                    }
                    if (pos in PADDLES) {
                        delete PADDLES[pos]
                    }
                    if (pos in BALLS) {
                        delete BALLS[pos]
                    }
                    break
                case 2: # BLOCK
                    if (pos in WALLS) {
                        delete WALLS[pos]
                    }
                    BLOCKS[pos] = 1
                    if (pos in PADDLES) {
                        delete PADDLES[pos]
                    }
                    if (pos in BALLS) {
                        delete BALLS[pos]
                    }
                    break
                case 3: # PADDLE
                    if (pos in WALLS) {
                        delete WALLS[pos]
                    }
                    if (pos in BLOCKS) {
                        delete BLOCKS[pos]
                    }
                    XPADDLE = X
                    if (!XDEST) {
                        XDEST = XPADDLE
                    }
                    YPADDLE = Y
                    PADDLES[pos] = 1
                    if (pos in BALLS) {
                        delete BALLS[pos]
                    }
                    break
                case 4: # BALL
                    if (pos in WALLS) {
                        delete WALLS[pos]
                    }
                    if (pos in BLOCKS) {
                        delete BLOCKS[pos]
                    }
                    if (pos in PADDLES) {
                        delete PADDLES[pos]
                    }
                    if (XBALL) {
                        XBALLPREV = XBALL
                        YBALLPREV = YBALL
                    }
                    XBALL = X
                    YBALL = Y
                    if (XBALLPREV) {
                        VXBALL = XBALL - XBALLPREV
                        VYBALL = YBALL - YBALLPREV
                    }
                    BALLS[pos] = 1
                    if (((YBALL + 2) == YPADDLE) && (VYBALL == -1)) {
                        # just bounced off paddle, compute new XDEST
                        if (DEBUG) {
                            printf "COMPUTING NEW XDEST for [%d,%d] <%d,%d> <%d>\n", XBALL, YBALL, VXBALL, VYBALL, XDEST > DFILE
                        }
                        split("", KILLS)
                        x = XBALL
                        y = YBALL
                        vx = VXBALL
                        vy = VYBALL
                        if (DEBUG) {
                            printf "  start: [%d,%d] <%d,%d>\n", x, y, vx, vy > DFILE
                        }
                        count = 0
                        while ((y + 1) < YPADDLE) {
                            xpos = (x + vx) SUBSEP y
                            ypos = x SUBSEP (y + vy)
                            pos = (x + vx) SUBSEP (y + vy)
                            while ((xpos in WALLS) || ((xpos in BLOCKS) && !(xpos in KILLS)) ||
                                   (ypos in WALLS) || ((ypos in BLOCKS) && !(ypos in KILLS)) ||
                                   (pos in WALLS) || ((pos in BLOCKS) && !(pos in KILLS))) {
                                if ((xpos in WALLS) || ((xpos in BLOCKS) && !(xpos in KILLS))) {
                                    if ((xpos in BLOCKS) && !(xpos in KILLS)) {
                                        KILLS[xpos] = 1
                                        if (DEBUG) {
                                            printf "KILL [%d,%d] from [%d,%d] <%d,%d>\n", (x + vx), y, x, y, vx, vy > DFILE
                                        }
                                    }
                                    vx = -vx
                                } else if ((ypos in WALLS) || ((ypos in BLOCKS) && !(ypos in KILLS))) {
                                    if ((ypos in BLOCKS) && !(ypos in KILLS)) {
                                        KILLS[ypos] = 1
                                        if (DEBUG) {
                                            printf "KILL [%d,%d] from [%d,%d] <%d,%d>\n", x, (y + vy), x, y, vx, vy > DFILE
                                        }
                                    }
                                    vy = -vy
                                } else if ((pos in WALLS) || ((pos in BLOCKS) && !(pos in KILLS))) {
                                    if ((pos in BLOCKS) && !(pos in KILLS)) {
                                        KILLS[pos] = 1
                                        if (DEBUG) {
                                            printf "KILL [%d,%d] from [%d,%d] <%d,%d>\n", (x + vx), (y + vy), x, y, vx, vy > DFILE
                                        }
                                    }
                                    vx = -vx
                                    vy = -vy
                                }
                                xpos = (x + vx) SUBSEP y
                                ypos = x SUBSEP (y + vy)
                                pos = (x + vx) SUBSEP (y + vy)
                            }
                            x += vx
                            y += vy
                            if (DEBUG) {
                                printf "   move: [%d,%d] <%d,%d>\n", x, y, vx, vy > DFILE
                            }
                            if (++count > 999999) {
                                aoc::compute_error("stuck in bounce detect loop")
                            }
                        }
                        XDEST = x
                        if (DEBUG) {
                            print "XDEST =", XDEST > DFILE
                            fflush(DFILE)
                        }
                    }
                    break
                default:
                    aoc::compute_error("illegal tile type " OUTPUT)
                }
                if (VIDEO) {
                    refresh_screen(PAUSING)
                }
                TASK = REPORT_X
                break
            case 4: # REPORT_ZERO
                if (OUTPUT != 0) {
                    aoc::compute_error("expected -1,0 as score lead-in")
                }
                TASK = REPORT_SCORE
                if (VIDEO) {
                    refresh_screen(NOT_PAUSING)
                }
                break
            case 5: # REPORT_SCORE
                SCORE = OUTPUT
                TASK = REPORT_X
                if (VIDEO) {
                    SCORE_DRAWN = 1
                    if (PAUSE_FOR_REFRESH) {
                        PAUSING = 1
                    }
                    refresh_screen(PAUSING)
                }
                break
            default:
                aoc::compute_error("unknown task " TASK)
            }
        }
    }
    if (VIDEO) {
        refresh_screen(NOT_PAUSING)
    }
    print SCORE
}
