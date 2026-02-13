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
    split("addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr", OPCODES)
    three_or_more = 0
}
(NF == 0) { next }
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
    num_matches = 0
    for (o in RESULT) {
        ++num_matches
        if (DEBUG > 1) {
            expect_if_matches = num_matches
        }
        for (r in RESULT[o]) {
            if (RESULT[o][r] != REGS[r]) {
                --num_matches
                break
            }
        }
        if (DEBUG > 1) {
            if (expect_if_matches == num_matches) {
                print "opcode", OPCODES[o], "matches" > DFILE
            }
        }
    }
    if (num_matches >= 3) {
        ++three_or_more
    }
    if (DEBUG) {
        print num_matches, "opcodes matched" > DFILE
    }
    next
}
{
    for (i = 1; i <= NF; ++i) {
        MEM[i - 1] = $i
    }
    for (o in OPCODES) {
        for (r in REGS) {
            RESULT[o][r] = REGS[r]
        }
        op(OPCODES[o], RESULT[o], MEM)
        if (DEBUG > 2) {
            printf "%s", OPCODES[o] > DFILE
            for (m in MEM) {
                printf " %d", MEM[m] > DFILE
            }
            printf ":" > DFILE
            for (r in REGS) {
                printf " %d", REGS[r] > DFILE
            }
            printf " ->" > DFILE
            for (r in RESULT[o]) {
                printf " %d", RESULT[o][r] > DFILE
            }
            printf "\n" > DFILE
        }
    }
}
END {
    print three_or_more
}
