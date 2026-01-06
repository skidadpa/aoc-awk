#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="([a-z][a-z][a-z][a-z])|([[:digit:]]+)|([-+*/])"
}
(NF == 2) && /^[a-z][a-z][a-z][a-z]: [[:digit:]]+$/ {
    VALUE[$1] = int($2)
    next
}
(NF != 4) {
    aoc::data_error()
}
/^[a-z][a-z][a-z][a-z]: [a-z][a-z][a-z][a-z] [-+*/] [a-z][a-z][a-z][a-z]$/ {
    COMPUTE[$1]["left"] = $2
    COMPUTE[$1]["operation"] = $3
    COMPUTE[$1]["right"] = $4
    next
}
{
    aoc::data_error()
}
function find_value(monkey) {
    if (!(monkey in VALUE)) {
        switch (COMPUTE[monkey]["operation"]) {
        case "+":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) + find_value(COMPUTE[monkey]["right"])
            break
        case "-":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) - find_value(COMPUTE[monkey]["right"])
            break
        case "*":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) * find_value(COMPUTE[monkey]["right"])
            break
        case "/":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) / find_value(COMPUTE[monkey]["right"])
            break
        default:
            aoc::compute_error("computing " monkey)
        }
    }
    return VALUE[monkey]
}
END {
    print find_value("root")
}
