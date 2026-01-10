#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("abcdefgh", temp, "")
    for (t in temp) {
        REGS[temp[t]] = 0
    }
}
/^((set)|(sub)|(mul)|(jnz)) (([a-h])|(-?[[:digit:]]+)) (([a-h])|(-?[[:digit:]]+))$/ {
    OP[NR] = $1
    DEST[NR] = $2
    VALUE[NR] = $3
    next
}
{ aoc::data_error("illegal instruction") }
END {
    PC = 1
    multiplies = 0
    for (count = 1; count <= 99999999 && (PC in OP); ++count) {
        if (DEBUG && (count % 1000000 == 0)) {
            print "...", count, "multiplies =", multiplies, "PC =", PC > DFILE
        }
        val = VALUE[PC]
        if (val in REGS) {
            val = REGS[val]
        }
        switch (OP[PC]) {
        case "set":
            target = DEST[PC]
            if (!(target in REGS)) {
                aoc::compute_error(target " is not a register")
            }
            REGS[target] = val
            break
        case "sub":
            target = DEST[PC]
            if (!(target in REGS)) {
                aoc::compute_error(target " is not a register")
            }
            REGS[target] -= val
            break
        case "mul":
            target = DEST[PC]
            if (!(target in REGS)) {
                aoc::compute_error(target " is not a register")
            }
            REGS[target] *= val
            ++multiplies
            break
        case "jnz":
            test = DEST[PC]
            if (test in REGS) {
                test = REGS[test]
            }
            if (test != 0) {
                PC = PC + val - 1
            }
            break
        default:
            aoc::compute_error("illegal instruction at " PC)
        }
        ++PC
    }
    if (count > 99999999) {
        aoc::compute_error("unresolved after " count " operations")
    }
    print multiplies
}
