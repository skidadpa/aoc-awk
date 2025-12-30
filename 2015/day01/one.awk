#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) { aoc::data_error() }
{
    down = gsub(/)/, "")
    print length($0) - down
}
