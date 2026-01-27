#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
{
    for (dx = 0; dx < $4; ++dx) for (dy = 0; dy < $5; ++dy) {
        if (++CLAIMS[$2+dx,$3+dy] == 2) {
            MULTI_CLAIMS[$2+dx,$3+dy] = 1
        }
    }
}
$0 !~ /^#[[:digit:]]+ @ [[:digit:]]+,[[:digit:]]+: [[:digit:]]+x[[:digit:]]+$/ { aoc::data_error() }
$1 != NR { aoc::data_error("out of order claim") }
END {
    print length(MULTI_CLAIMS)
}
