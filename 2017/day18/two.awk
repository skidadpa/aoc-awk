#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("abcdefghijklmnopqrstuvwxyz", temp, "")
    for (t in temp) {
        REGS[0][temp[t]] = 0
        REGS[1][temp[t]] = 0
    }
    REGS[1]["p"] = 1
}
/^((snd)|(rcv)) (([a-z])|(-?[[:digit:]]+))$/ {
    OP[NR] = $1
    DEST[NR] = $2
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
    OP[0] = "stopped"
    VALUE[0] = 0
    PC[0] = PC[1] = 1
    SENT[0] = SENT[1] = 0
    split("", QUEUE[0])
    split("", QUEUE[1])
    RCVD[0] = RCVD[1] = 0
    for (count = 1; count <= 99999999; ++count) {
        # It would be more efficient to run each program until it stalls,
        # although in practice it does not matter here. If we needed to
        # analyze and optimize the program execution, it would make sense
        # to alter the execution model as well.
        for (prog = 0; prog <= 1; ++prog) {
            val = VALUE[PC[prog]]
            if (val in REGS[prog]) {
                val = REGS[prog][val]
            }
            stopped[prog] = 0
            switch (OP[PC[prog]]) {
            case "stopped":
                stopped[prog] = 1
                break
            case "snd":
                QUEUE[prog][++SENT[prog]] = val
                break
            case "rcv":
                target = DEST[PC[prog]]
                if (!(target in REGS[prog])) {
                    aoc::compute_error(target " is not a register")
                }
                head = RCVD[prog] + 1
                if (head in QUEUE[!prog]) {
                    REGS[prog][target] = QUEUE[!prog][head]
                    delete QUEUE[!prog][head]
                    ++RCVD[prog]
                } else {
                    stopped[prog] = 1
                }
                break
            case "set":
                target = DEST[PC[prog]]
                if (!(target in REGS[prog])) {
                    aoc::compute_error(target " is not a register")
                }
                REGS[prog][target] = val
                break
            case "add":
                target = DEST[PC[prog]]
                if (!(target in REGS[prog])) {
                    aoc::compute_error(target " is not a register")
                }
                REGS[prog][target] += val
                break
            case "mul":
                target = DEST[PC[prog]]
                if (!(target in REGS[prog])) {
                    aoc::compute_error(target " is not a register")
                }
                REGS[prog][target] *= val
                break
            case "mod":
                target = DEST[PC[prog]]
                if (!(target in REGS[prog])) {
                    aoc::compute_error(target " is not a register")
                }
                if ((val <= 0) || (REGS[prog][target] < 0)) {
                    aoc::compute_error(REGS[prog][target] " % " val " is not defined")
                }
                REGS[prog][target] %= val
                break
            case "jgz":
                test = DEST[PC[prog]]
                if (test in REGS[prog]) {
                    test = REGS[prog][test]
                }
                if (test > 0) {
                    PC[prog] = PC[prog] + val - 1
                }
                break
            default:
                aoc::compute_error("illegal instruction at " PC[prog])
            }
            if (!stopped[prog]) {
                ++PC[prog]
                if (!(PC[prog] in OP)) {
                    PC[prog] = 0
                }
            }
        }
        if (stopped[0] && stopped[1]) {
            print SENT[1]
            exit
        }
    }
    aoc::compute_error("still running after " count " operations")
}
