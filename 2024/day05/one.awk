#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "|"
}
/^[[:digit:]]+\|[[:digit:]]+$/ {
    if (FS != "|") {
        aoc::data_error("rule in wrong location")
    }
    AFTER[$1][$2] = 1
    next
}
/^$/ {
    if (FS != "|") {
        aoc::data_error("rule divider in wrong location")
    }
    FS = ","
    next
}
/^[[:digit:]]+(,[[:digit:]]+)+$/ {
    if (FS != ",") {
        aoc::data_error("manual pages in wrong location")
    }
    split("", earlier_pages)
    earlier_pages[1] = $1
    for (p = 2; p <= NF; ++p) {
        if ($p in AFTER) {
            for (i in earlier_pages) {
                if (earlier_pages[i] in AFTER[$p]) {
                    next
                }
            }
        }
        earlier_pages[p] = $p
    }
    mid = (NF + 1)/ 2
    middles_sum += $mid
    next
}
{
    aoc::data_error()
}
END {
    print middles_sum
}
