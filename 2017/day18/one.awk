#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("abcdefghijklmnopqrstuvwxyz", temp, "")
    for (t in temp) {
        REGS[temp[t]] = 0
    }
}
/^((snd)|(rcv)) (([a-z])|(-?[[:digit:]]+))$/ {
    OP[NR] = $1
    VALUE[NR] = $2
    next
}
/^((set)|(add)|(mul)|(mod)|(jgz)) (([a-z])|(-?[[:digit:]]+)) (([a-z])|(-?[[:digit:]]+))$/ {
    OP[NR] = $1
    DEST[NR] = $2
    VALUE[NR] = $3
    next
}
{ aoc::data_error("illegal instruction") }
END {
    PC = 1
    sound = "NONE"
    for (count = 1; count <= 99999999 && (PC in OP); ++count) {
        val = VALUE[PC]
        if (val in REGS) {
            val = REGS[val]
        }
        switch (OP[PC]) {
        case "snd":
            sound = val
            break
        case "rcv":
            if (val) {
                print sound
                exit
            }
            break
        case "set":
            target = DEST[PC]
            if (!(target in REGS)) {
                aoc::compute_error(target " is not a register")
            }
            REGS[target] = val
            break
        case "add":
            target = DEST[PC]
            if (!(target in REGS)) {
                aoc::compute_error(target " is not a register")
            }
            REGS[target] += val
            break
        case "mul":
            target = DEST[PC]
            if (!(target in REGS)) {
                aoc::compute_error(target " is not a register")
            }
            REGS[target] *= val
            break
        case "mod":
            target = DEST[PC]
            if (!(target in REGS)) {
                aoc::compute_error(target " is not a register")
            }
            if ((val <= 0) || (REGS[target] < 0)) {
                aoc::compute_error(REGS[target] " % " val " is not defined")
            }
            REGS[target] %= val
            break
        case "jgz":
            test = DEST[PC]
            if (test in REGS) {
                test = REGS[test]
            }
            if (test > 0) {
                PC = PC + val - 1
            }
            break
        default:
            aoc::compute_error("illegal instruction at " PC)
        }
        ++PC
    }
    aoc::compute_error("unresolved after " count " operations")
}
