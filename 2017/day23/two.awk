#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
@load "./day23"

#
# This solution requires analyzing the input program and converting it into a form that
# executes in a reasonable amount of time. Currently a specific solution is provided to
# the known input programs.
#
# It seems that at least some of the generated input programs function the same except
# that they initialize b to a different value in the first instruction. This solution
# takes that into account and uses the initial values of a and b.
#

BEGIN {
    split("abcdefgh", temp, "")
    for (t in temp) {
        REGS[temp[t]] = 0
    }
    REGS["a"] = 1
    DEBUG = "graphviz"
}
/^((set)|(sub)|(mul)|(jnz)) (([a-h])|(-?[[:digit:]]+)) (([a-h])|(-?[[:digit:]]+))$/ {
    if (NR == 1) {
        if (($1 != "set") || ($2 != "b") || ($3 in REGS)) {
            aoc::compute_error("input not conformant with current constrained solution")
        }
        REGS[$2] = $3
    }
    next
}
{ aoc::data_error("illegal instruction") }
END {
    print day23_2017_part2(REGS["a"],REGS["b"])
}
