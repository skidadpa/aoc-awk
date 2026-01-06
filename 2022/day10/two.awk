#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    X = 1
}
function abs(x) {
    return (x >= 0) ? x : -x;
}
function advance_time(  signal_strength) {
    printf("%c", (abs((cycle % 40) - X) <= 1) ? "#" : ".")
    if ((++cycle % 40) == 0) {
        printf("\n")
    }
}
/^noop$/ {
    advance_time()
    next
}
/^addx -?[[:digit:]]+$/ {
    advance_time()
    advance_time()
    X += int($2)
    next
}
{
    aoc::data_error()
}
