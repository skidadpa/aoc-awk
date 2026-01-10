#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("abcdefgh", temp, "")
    for (t in temp) {
        REGS[temp[t]] = 0
    }
    REGS["a"] = 1
    DEBUG = "graphviz"
}
/^((set)|(sub)|(mul)|(jnz)) (([a-h])|(-?[[:digit:]]+)) (([a-h])|(-?[[:digit:]]+))$/ {
    OP[NR] = $1
    DEST[NR] = $2
    VALUE[NR] = $3
    INSTRUCTION[NR] = $0
    switch ($1) {
    case "set":
        CODE[NR] = DEST[NR] " = " VALUE[NR] ";"
        break
    case "sub":
        CODE[NR] = DEST[NR] " -= " VALUE[NR] ";"
        break
    case "mul":
        CODE[NR] = DEST[NR] " *= " VALUE[NR] "; ++multiplies;"
        break
    case "jnz":
        break
    default:
        aoc::data_error("unsupported opcode " $1)
    }
    next
}
{ aoc::data_error("illegal instruction") }
END {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    BASIC_BLOCKS[1] = "NEW"
    for (m = 1; m <= NR; ++m) {
        if (DEBUG && DEBUG != "graphviz") {
            print "instruction", m, ":", INSTRUCTION[m] > DFILE
        }
        if (OP[m] == "jnz") {
            if (DEBUG && DEBUG != "graphviz") {
                print "jump instruction" > DFILE
            }
            target = m + VALUE[m]
            if (target in OP) {
                JUMP_DEST[m] = target
                BASIC_BLOCKS[target] = "NEW"
                if (DEBUG && DEBUG != "graphviz") {
                    print "creating BASIC_BLOCK at", target > DFILE
                }
                if (((target - 1) in OP) && (OP[target - 1] != "jnz")) {
                    FALLTHROUGH_DEST[target - 1] = target
                    if (DEBUG && DEBUG != "graphviz") {
                        print "creating WALK from", target - 1, "to", target > DFILE
                    }
                }
            } else {
                JUMP_DEST[m] = "END"
            }
            if (DEBUG && DEBUG != "graphviz") {
                print "JUMP dest is", JUMP_DEST[m] > DFILE
            }
            if (DEST[m] in REGS) {
                target = m + 1
                if (target in OP) {
                    FALLTHROUGH_DEST[m] = target
                    if (DEBUG && DEBUG != "graphviz") {
                        print "creating WALK from", m, "to", target > DFILE
                    }
                    BASIC_BLOCKS[target] = "NEW"
                    if (DEBUG && DEBUG != "graphviz") {
                        print "creating BASIC_BLOCK at", target > DFILE
                    }
                } else {
                    FALLTHROUGH_DEST[m] = "END"
                }
            }
        }
    }
    BASIC_BLOCKS["START"] = "START"
    WALK["START"] = 1
    BASIC_BLOCKS["END"] = "END"
    for (m = 1; m <= NR; ++m) {
        if (m in BASIC_BLOCKS) {
            b = m
            BASIC_BLOCKS[b] = INSTRUCTION[m]
        } else {
            BASIC_BLOCKS[b] = BASIC_BLOCKS[b] "\\n" INSTRUCTION[m]
        }
        if (m in CODE) {
            if (b in BLOCK_CODE) {
                BLOCK_CODE[b] = BLOCK_CODE[b] "\\n" CODE[m]
            } else {
                BLOCK_CODE[b] = CODE[m]
            }
        }
        if (m in JUMP_DEST) {
            if (b in BRANCH) {
                aoc::compute_error("duplicate branch from " b " at " m)
            }
            BRANCH[b] = JUMP_DEST[m]
            if (!(BRANCH[b] in BASIC_BLOCKS)) {
                aoc::compute_error("branch to illegal " BRANCH[b] " at " m)
            }
        }
        if (m in FALLTHROUGH_DEST) {
            if (b in WALK) {
                aoc::compute_error("duplicate fallthrough from " b " at " m)
            }
            WALK[b] = FALLTHROUGH_DEST[m]
            if (!(WALK[b] in BASIC_BLOCKS)) {
                aoc::compute_error("walk to illegal " WALK[b] " at " m)
            }
        }
    }
    if ((DEBUG == "graphviz") || (DEBUG == "graphviz_debug")) {
        # output is a DOT digraph for graphviz
        print "digraph {"
        for (b in BASIC_BLOCKS) {
            print " ", b, "[label=\"" BASIC_BLOCKS[b] "\"]"
            if (b in WALK) {
                print " ", b, "->", WALK[b], "[style=\"dashed\"]"
            }
            if (b in BRANCH) {
                print " ", b, "->", BRANCH[b], "[color=\"blue\"]"
            }
        }
        print "}"
        exit
    }
    # output is a C program that generates the answer to stdout
    print "#include <stdio.h>"
    print ""
    print "long a=1;"
    print "long b=0;"
    print "long c=0;"
    print "long d=0;"
    print "long e=0;"
    print "long f=0;"
    print "long g=0;"
    print "long h=0;"
    print "unsigned long multiplies = 0;"
    print ""
    print "void run_program() {"


    print "}"
    print ""
    print "int main() {"
    print "    run_program();"
    print "    printf(\"%lu\\n\", multiplies);"
    print "    return 0;"
    print "}"
}
