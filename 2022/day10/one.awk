#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    X = 1
}
function advance_time(  signal_strength) {
    ++cycle
    if (((cycle - 20) % 40 == 0)) {
        signal_strength = X * cycle
        sum += signal_strength
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
END {
    print sum
}
