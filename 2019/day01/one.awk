#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }
{
    TOTAL += int($1 / 3) - 2
}
END {
    print TOTAL
}
