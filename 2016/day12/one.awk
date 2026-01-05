#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    REGISTERS["a"] = REGISTERS["b"] = REGISTERS["c"] = REGISTERS["d"] = 0
    split("COPY INCR JUMP", OPCODES)
    for (o in OPCODES) {
        OPCODE_NUMBER[OPCODES[o]] = o
    }
}
/^cpy ([abcd]|(-?[[:digit:]]+)) [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["COPY"]
    DST[NR] = $3
    VAL[NR] = $2
    next
}
/^inc [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["INCR"]
    DST[NR] = $2
    VAL[NR] = 1
    next
}
/^dec [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["INCR"]
    DST[NR] = $2
    VAL[NR] = -1
    next
}
/^jnz ([abcd]|(-?[[:digit:]]+)) -?[[:digit:]]+$/ {
    OP[NR] = OPCODE_NUMBER["JUMP"]
    DST[NR] = $3
    VAL[NR] = $2
    next
}
{
    aoc::data_error("unrecognized instruction")
}
END {
    pc = 1
    while (pc <= NR) {
        next_pc = pc + 1
        switch (OP[pc]) {
        case 1: # COPY
            val = (VAL[pc] in REGISTERS) ? REGISTERS[VAL[pc]] : VAL[pc]
            REGISTERS[DST[pc]] = val
            break
        case 2: # INCR
            REGISTERS[DST[pc]] += VAL[pc]
            break
        case 3: # JUMP
            val = (VAL[pc] in REGISTERS) ? REGISTERS[VAL[pc]] : VAL[pc]
            if (val) {
                next_pc = pc + DST[pc]
            }
            break
        default:
            aoc::compute_error("unrecognized OPCODE " OP[pc] " at pc " pc)
        }
        pc = next_pc
    }
    print REGISTERS["a"]
}
