#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
@load "./day23"
function tab(indent,   rslt) {
    rslt = ""
    while (indent--) {
        rslt = rlst "    "
    }
    return rslt
}
function analyze_code(b) {
    if (b in ANALYZED) {
        ++LOOP_START[b]
        return
    }
    ANALYZED[b] = 1
    # while (!(b in BLOCK_CODE) && (b in WALK) && !(b in BRANCH)) {
    #     b = WALK[b]
    # }
    if ((b in WALK) && (b in BRANCH)) {
        if (       (WALK[b] in WALK) && !(WALK[b] in BRANCH) && \
                   (BRANCH[b] in WALK) && !(BRANCH[b] in BRANCH) && \
                   (WALK[WALK[b]] == WALK[BRANCH[b]])) {
            # simple two-sided conditional, don't look for loops
            analyze_code(WALK[b])
        } else if ((WALK[b] in WALK) && !(WALK[b] in BRANCH) && \
                   (WALK[WALK[b]] == BRANCH[b]])) {
            # simple one-sided conditional, don't look for loops
            analyze_code(BRANCH[b])
        } else if ((BRANCH[b] in WALK) && !(BRANCH[b] in BRANCH) && \
                   (WALK[BRANCH[b]] == WALK[b]])) {
            # simple one-sided conditional, don't look for loops
            analyze_code(WALK[b])
        } else {
            analyze_code(BRANCH[b])
            analyze_code(WALK[b])
        }
    } else if (b in WALK) {
        analyze_code(WALK[b])
    } else if (b in BRANCH) {
        analyze_code(BRANCH[b])
    } else if (b != "END") {
        aoc::compute_error("non-END terminal state " b)
    }
}
function generate_code(indent, b,   lines, i) {
    GENERATED[block] = 1
    if (b in LOOP_START) {
        for (i = 1; i <= LOOP_START[b]; ++i) {
            print tab(indent) "do {"
            ++indent
        }
    }
    print tab(indent) "/*"
    split(BASIC_BLOCKS[b], lines, "\\n")
    for (i in lines) {
        print tab(indent) " * " lines[i]
    }
    print tab(indent) " */"
    if (b in BLOCK_CODE) {
        split(BLOCK_CODE, lines, "\\n")
        for (i in lines) {
            print tab(indent) lines[i]
        }
    }
    if (b in BRANCH) {
        if (BRANCH[b] in GENERATED) {
            if (!(b in LOOP_START)) {
                aoc::compute_error(b " BRANCH dest is not a LOOP START")
            }
            --indent
            print tab(indent) "} while (" BRANCH_TEST[b] ");"
        } else {
        LOOP_START[b]
        WALK[b]
        BRANCH[b]
        BRANCH_TEST[b]
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
                JUMP_TEST[m] = DEST[m]
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
                JUMP_TEST[m] = DEST[m]
            }
            if (DEBUG && DEBUG != "graphviz") {
                print "JUMP dest is", JUMP_DEST[m], "test is", JUMP_TEST[m] > DFILE
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
                    if (DEBUG && DEBUG != "graphviz") {
                        print "creating WALK from", m, "to END" > DFILE
                    }
                    FALLTHROUGH_DEST[m] = "END"
                }
            } else {
                # convert JUMP to FALLTHROUGH
                if (DEST[m]) {
                    # always taken
                    if (DEBUG && DEBUG != "graphviz") {
                        print "converting JUMP to WALK from", m > DFILE
                    }
                    FALLTHROUGH_DEST[m] = JUMP_DEST[m]
                } else {
                    # never taken, useless code but make a block anyway
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
                        if (DEBUG && DEBUG != "graphviz") {
                            print "creating WALK from", m, "to END" > DFILE
                        }
                        FALLTHROUGH_DEST[m] = "END"
                    }
                }
                delete JUMP_DEST[m]
                delete JUMP_TEST[m]
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
            BRANCH_TEST[b] = JUMP_TEST[m]
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

    analyze_code(WALK["START"])
    generate_code(1, WALK["START"])

    print "}"
    print ""
    print "int main() {"
    print "    run_program();"
    print "    printf(\"%lu\\n\", multiplies);"
    print "    return 0;"
    print "}"
}
