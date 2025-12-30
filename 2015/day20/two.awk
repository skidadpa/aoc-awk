#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) || ($0 !~ /^[[:digit:]]+$/) { aoc::data_error() }
{
    N_HOUSES = $1/10
    for (e = 1; e <= N_HOUSES; ++e) for (h = e; (h <= N_HOUSES) && (h <= 50 * e); h += e) HOUSES[h] += e * 11
    if (DEBUG) {
        for (h = 1; h <= N_HOUSES; ++h) printf("%d: %d\n",h, HOUSES[h]) > DFILE
    }
    for (h = 1; h <= N_HOUSES; ++h) if (HOUSES[h] >= $1) break
    print h
}
