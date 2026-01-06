#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    elf = 1
}
/^\s*$/ {
    ++elf
    next
}
{
    calories[elf] += $1
}
END {
    n = asort(calories, largest, "@val_num_desc")
    if (n < 3) { aoc::data_error() }
    print largest[1] + largest[2] + largest[3]
}
