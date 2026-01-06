#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("( [ { <", t1); split(") ] } >", t2); split("3 57 1197 25137", t3)
    for (i in t1) {
        pairs[t1[i]] = t2[i]
        bugs[t2[i]] = t3[i]
    }
}
function nextblock(pc, end,  seeking) {
    while (pc > 0 && pc <= end) {
        op = substr(program, pc++, 1)
        if (op == seeking) return pc
        if (op in bugs) return -bugs[op]
        if (op in pairs) pc = nextblock(pc, end, pairs[op])
    }
    return pc
}
{
    program = $0
    pc = 1
    while (pc > 0 && pc <= length(program)) pc = nextblock(pc, length(program))
    if (pc < 0) score += -pc
}
END { print score }
