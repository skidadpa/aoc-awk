#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="([a-z]+)|([-+][[:digit:]]+)"
    REG["a"] = REG["b"] = 0
    IP = 1
    if (DEBUG) {
        print "PROGRAM:" > DFILE
    }
}
/^hlf [ab]$/ || /^tpl [ab]$/ || /^inc [ab]$/ {
    OP[NR] = $1
    OP_REG[NR] = $2
    if (DEBUG) print NR, ":", $1, $2, "(arithmetic operation)" > DFILE
    next
}
/^jmp [-+][[:digit:]]+/ {
    OP[NR] = $1
    OP_OFF[NR] = $2
    if (DEBUG) print NR, ":", $1, $2, "(unconditional jump)" > DFILE
    next
}
/^jie [ab], [-+][[:digit:]]+/ || /^jio [ab], [-+][[:digit:]]+/ {
    OP[NR] = $1
    OP_REG[NR] = $2
    OP_OFF[NR] = $3
    if (DEBUG) print NR, ":", $1, $2, $3, "(conditional jump)" > DFILE
    next
}
{
    aoc::data_error()
}
END {
    while (IP <= NR) {
        jumping = 0
        if (DEBUG) printf("Executing %d : %s %s %s ... ", IP, OP[IP], OP_REG[IP], OP_OFF[IP])
        switch (OP[IP]) {
        case "hlf":
            REG[OP_REG[IP]] /= 2
            break
        case "tpl":
            REG[OP_REG[IP]] *= 3
            break
        case "inc":
            ++REG[OP_REG[IP]]
            break
        case "jmp":
            jumping = 1
            break
        case "jie":
            jumping = (REG[OP_REG[IP]] % 2 == 0)
            break
        case "jio":
            jumping = (REG[OP_REG[IP]] == 1)
            break
        default:
            aoc::compute_error()
        }
        if (jumping) {
            IP += OP_OFF[IP]
        } else {
            ++IP
        }
        if (DEBUG) print " IP =", IP, "A =", REG["a"], "B =", REG["b"] > DFILE
    }
    if (DEBUG) print "stopped at IP =", IP, "A =", REG["a"], "B =", REG["b"] > DFILE
    print REG["b"]
}
