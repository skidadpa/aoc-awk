#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
{
    unmatched = 1
    for (dx = 0; dx < $4; ++dx) for (dy = 0; dy < $5; ++dy) {
        if ((($2+dx) SUBSEP ($3+dy)) in FIRST_CLAIMS) {
            unmatched = 0
            if (FIRST_CLAIMS[$2+dx,$3+dy] in UNMATCHED_CLAIMS) {
                delete UNMATCHED_CLAIMS[FIRST_CLAIMS[$2+dx,$3+dy]]
            }
        } else {
            FIRST_CLAIMS[$2+dx,$3+dy] = $1
        }
    }
    if (unmatched) {
        UNMATCHED_CLAIMS[$1] = 1
    }
}
$0 !~ /^#[[:digit:]]+ @ [[:digit:]]+,[[:digit:]]+: [[:digit:]]+x[[:digit:]]+$/ { aoc::data_error() }
$1 != NR { aoc::data_error("out of order claim") }
END {
    if (length(UNMATCHED_CLAIMS) != 1) {
        aoc::compute_error("did not resolve to a single unmatched claim")
    }
    for (claim in UNMATCHED_CLAIMS) {
        print claim
    }
}
