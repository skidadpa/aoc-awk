#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function move(n) {
    DIAL += n
    DIAL %= 100
    if (DIAL < 0) {
        DIAL += 100
    }
    if (DIAL == 0) {
        ++COUNT
    }
}
BEGIN {
    DIAL = 50
    COUNT = 0
    FPAT = "[[:digit:]]+"
}
/^L[[:digit:]]+$/ {
    move(0 - $1)
    next
}
/^R[[:digit:]]+$/ {
    move(0 + $1)
    next
}
{
    aoc::data_error("illegal rotation: " $0)
}
END {
    print COUNT
}
