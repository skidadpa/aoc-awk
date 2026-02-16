#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function op(regs, mem) {
    switch(mem[0]) {
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
        aoc::compute_error("unknown opcode " mem[0])
    }
}
BEGIN {
    for (i = 0; i < 6; ++i) {
        REGS[i] = 0
    }
    DEBUG = 1
}
(NR == 1) && ($0 ~ /^#ip [[:digit:]]$/) {
    IP = $2
    next
}
$0 !~ /^((addr)|(addi)|(mulr)|(muli)|(banr)|(bani)|(borr)|(bori)|(setr)|(seti)|(gtir)|(gtri)|(gtrr)|(eqir)|(eqri)|(eqrr)) [[:digit:]]+ [[:digit:]]+ [[:digit:]]$/ {
    aoc::data_error()
}
{
    loc = NR - 2
    for (i = 1; i <= NF; ++i) {
        MEM[loc][i - 1] = $i
    }
}
END {
    REGS[0] = 1
    if (MEM[REGS[IP]][3] != IP) {
        aoc::compute_error("unsupported program input")
    }
    while ((MEM[REGS[IP]][0] != "seti") || (MEM[REGS[IP]][3] != IP)) {
        if (DEBUG) {
            if ((++instruction_count % 1000000) == 0) {
                print instruction_count, "instructions executed" > DFILE
            }
        }
        op(REGS, MEM[REGS[IP]])
        if (MEM[REGS[IP]][0] != "seti") {
            value = REGS[MEM[REGS[IP]][3]]
        }
        ++REGS[IP]
    }
    sum_factors = 0
    for (potential_factor = 1; potential_factor <= value; ++potential_factor) {
        if (value % potential_factor == 0) {
            sum_factors += potential_factor
        }
    }
    print sum_factors
}
