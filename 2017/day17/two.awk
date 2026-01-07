#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 1
}
$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }
{
    STEP = $1
    pos = 0
    size = 1
    successor = 0
    for (count = 1; count <= 50000000; ++count) {
        pos = (pos + STEP) % size
        ++pos
        ++size
        if (pos == 1) {
            successor = count
        }
    }
    print successor
}
