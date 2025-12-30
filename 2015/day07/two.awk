#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = " -> "
}
(NF != 2) { aoc::data_error() }
{
    logic[$2] = $1
}
function value(wire,    circuit) {
    if (wire in cache) return cache[wire]
    if (wire ~ /^[0-9]+$/) return wire+0
    n = split(wire, circuit, " ")
    if (n == 1 && circuit[1] in logic)
        return cache[wire] = value(logic[circuit[1]])
    if (n == 2 && circuit[1] == "NOT")
        return cache[wire] = and(compl(value(circuit[2])), 0xffff)
    if (n == 3 && circuit[2] == "AND")
        return cache[wire] = and(value(circuit[1]), value(circuit[3]))
    if (n == 3 && circuit[2] == "OR")
        return cache[wire] = or(value(circuit[1]), value(circuit[3]))
    if (n == 3 && circuit[2] == "LSHIFT")
        return cache[wire] = and(lshift(value(circuit[1]), value(circuit[3])), 0xffff)
    if (n == 3 && circuit[2] == "RSHIFT")
        return cache[wire] = rshift(value(circuit[1]), value(circuit[3]))
    aoc::data_error()
}
END {
    if (!("a" in logic)) {
        for (wire in logic) print wire, ":", value(wire)
        exit
    }
    logic["b"] = value("a")
    delete cache
    print value("a")
}
