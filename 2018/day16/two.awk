#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function op(opcode, regs, mem) {
    switch(opcode) {
    case "addr":
        regs[mem[3]] = regs[mem[1]] + regs[mem[2]]
        break
    case "addi":
        regs[mem[3]] = regs[mem[1]] + mem[2]
        break
    case "mulr":
        regs[mem[3]] = regs[mem[1]] * regs[mem[2]]
        break
    case "muli":
        regs[mem[3]] = regs[mem[1]] * mem[2]
        break
    case "banr":
        regs[mem[3]] = and(regs[mem[1]], regs[mem[2]])
        break
    case "bani":
        regs[mem[3]] = and(regs[mem[1]], mem[2])
        break
    case "borr":
        regs[mem[3]] = or(regs[mem[1]], regs[mem[2]])
        break
    case "bori":
        regs[mem[3]] = or(regs[mem[1]], mem[2])
        break
    case "setr":
        regs[mem[3]] = regs[mem[1]]
        break
    case "seti":
        regs[mem[3]] = mem[1]
        break
    case "gtir":
        regs[mem[3]] = (mem[1] > regs[mem[2]])
        break
    case "gtri":
        regs[mem[3]] = (regs[mem[1]] > mem[2])
        break
    case "gtrr":
        regs[mem[3]] = (regs[mem[1]] > regs[mem[2]])
        break
    case "eqir":
        regs[mem[3]] = (mem[1] == regs[mem[2]])
        break
    case "eqri":
        regs[mem[3]] = (regs[mem[1]] == mem[2])
        break
    case "eqrr":
        regs[mem[3]] = (regs[mem[1]] == regs[mem[2]])
        break
    default:
        aoc::compute_error("unknown opcode " opcode)
    }
}
BEGIN {
    FPAT = "[[:digit:]]+"
    split("addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr", OPERATIONS)
    last_blank_line = -1
    querying_complete = 0
    split("", OPCODES)
}
(NF == 0) {
    if (!querying_complete) {
        if (last_blank_line == (NR - 1)) {
            for (opcode in CANDIDATE_OPERATIONS) {
                for (operation in CANDIDATE_OPERATIONS[opcode]) {
                    CANDIDATE_OPCODES[operation][opcode] = 1
                }
            }
            if (DEBUG > 2) {
                print "initial pairings:" > DFILE
                for (opcode in CANDIDATE_OPERATIONS) {
                    printf "%d is a candidate for:", opcode > DFILE
                    for (operation in CANDIDATE_OPERATIONS[opcode]) {
                        printf " %s", OPERATIONS[operation] > DFILE
                    }
                    printf "\n" > DFILE
                }
                for (operation in CANDIDATE_OPCODES) {
                    printf "%s is one of:", OPERATIONS[operation] > DFILE
                    for (opcode in CANDIDATE_OPCODES[operation]) {
                        printf " %d", opcode > DFILE
                    }
                    printf "\n" > DFILE
                }
            }
            do {
                split("", PAIRINGS_TO_DELETE)
                for (opcode in CANDIDATE_OPERATIONS) {
                    if (length(CANDIDATE_OPERATIONS[opcode]) == 1) {
                        for (operation in CANDIDATE_OPERATIONS[opcode]) {
                            break
                        }
                        if (DEBUG > 2) {
                            print "opcode", opcode, "matches", OPERATIONS[operation] > DFILE
                        }
                        OPCODES[opcode] = OPERATIONS[operation]
                        for (o in CANDIDATE_OPCODES[operation]) if (o != opcode) {
                            PAIRINGS_TO_DELETE[o] = operation
                        }
                    }
                }
                for (operation in CANDIDATE_OPCODES) {
                    if (length(CANDIDATE_OPCODES[operation]) == 1) {
                        for (opcode in CANDIDATE_OPCODES[operation]) {
                            break
                        }
                        if (DEBUG > 2) {
                            print "opcode", opcode, "matches", OPERATIONS[operation] > DFILE
                        }
                        OPCODES[opcode] = OPERATIONS[operation]
                        for (o in CANDIDATE_OPERATIONS[opcode]) if (o != operation) {
                            PAIRINGS_TO_DELETE[opcode] = o
                        }
                    }
                }
                for (opcode in PAIRINGS_TO_DELETE) {
                    operation = PAIRINGS_TO_DELETE[opcode]
                    delete CANDIDATE_OPERATIONS[opcode][operation]
                    delete CANDIDATE_OPCODES[operation][opcode]
                }
                if (DEBUG > 2) {
                    print "after a round of trimming:" > DFILE
                    for (opcode in CANDIDATE_OPERATIONS) {
                        printf "%d is a candidate for:", opcode > DFILE
                        for (operation in CANDIDATE_OPERATIONS[opcode]) {
                            printf " %s", OPERATIONS[operation] > DFILE
                        }
                        printf "\n" > DFILE
                    }
                    for (operation in CANDIDATE_OPCODES) {
                        printf "%s is one of:", OPERATIONS[operation] > DFILE
                        for (opcode in CANDIDATE_OPCODES[operation]) {
                            printf " %d", opcode > DFILE
                        }
                        printf "\n" > DFILE
                    }
                }
            } while (length(PAIRINGS_TO_DELETE) > 0)
            if (DEBUG > 2) {
                print "final pairings:" > DFILE
                for (opcode in CANDIDATE_OPERATIONS) {
                    printf "%d is a candidate for:", opcode > DFILE
                    for (operation in CANDIDATE_OPERATIONS[opcode]) {
                        printf " %s", OPERATIONS[operation] > DFILE
                    }
                    printf "\n" > DFILE
                }
                for (operation in CANDIDATE_OPCODES) {
                    printf "%s is one of:", OPERATIONS[operation] > DFILE
                    for (opcode in CANDIDATE_OPCODES[operation]) {
                        printf " %d", opcode > DFILE
                    }
                    printf "\n" > DFILE
                }
            }
            for (opcode in CANDIDATE_OPERATIONS) if (length(CANDIDATE_OPERATIONS[opcode]) != 1) {
                aoc::compute_error("did not resolve all candidate operations")
            }
            for (operation in CANDIDATE_OPCODES) if (length(CANDIDATE_OPCODES[operation]) != 1) {
                aoc::compute_error("did not resolve all candidate opcodes")
            }
            if (DEBUG) {
                print "OPCODE TABLE" > DFILE
                for (opcode in OPCODES) {
                    print opcode, ":", OPCODES[opcode]
                }
            }
            REGS[0] = REGS[1] = REGS[2] = REGS[3] = 0
            querying_complete = 1
        } else {
            last_blank_line = NR
        }
    }
    next
}
(NF != 4) { aoc::data_error("all lines must contain 4 numbers") }
/^Before/ {
    for (i = 1; i <= NF; ++i) {
        REGS[i - 1] = $i
    }
    next
}
/^After/ {
    for (i = 1; i <= NF; ++i) {
        REGS[i - 1] = $i
    }
    for (operation in RESULT) {
        for (r in RESULT[operation]) {
            if (RESULT[operation][r] != REGS[r]) {
                delete CANDIDATE_OPERATIONS[MEM[0]][operation]
                break
            }
        }
        if (DEBUG > 4) {
            if (operation in CANDIDATE_OPERATIONS[MEM[0]]) {
                print "opcode", MEM[0], "is a candidate for", OPERATIONS[operation] > DFILE
            }
        }
    }
    next
}
{
    for (i = 1; i <= NF; ++i) {
        MEM[i - 1] = $i
    }
    if (querying_complete) {
        op(OPCODES[MEM[0]], REGS, MEM)
    } else {
        if (!(MEM[0] in CANDIDATE_OPERATIONS)) {
            for (operation in OPERATIONS) {
                CANDIDATE_OPERATIONS[MEM[0]][operation] = 1
            }
        }
        for (operation in CANDIDATE_OPERATIONS[MEM[0]]) {
            for (r in REGS) {
                RESULT[operation][r] = REGS[r]
            }
            op(OPERATIONS[operation], RESULT[operation], MEM)
            if (DEBUG > 2) {
                printf "%s", OPERATIONS[operation] > DFILE
                for (m in MEM) {
                    printf " %d", MEM[m] > DFILE
                }
                printf ":" > DFILE
                for (r in REGS) {
                    printf " %d", REGS[r] > DFILE
                }
                printf " ->" > DFILE
                for (r in RESULT[operation]) {
                    printf " %d", RESULT[operation][r] > DFILE
                }
                printf "\n" > DFILE
            }
        }
    }
}
END {
    print REGS[0]
}
