#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }
{
    fuel = int($1 / 3) - 2
    while (fuel > 0) {
        TOTAL += fuel
        fuel = int(fuel / 3) - 2
    }
}
END {
    print TOTAL
}
