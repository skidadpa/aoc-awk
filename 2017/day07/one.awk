#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="[[:lower:]]+|[[:digit:]]+"
}
$0 !~ /^[[:lower:]]+ \([[:digit:]]+\)( -> [[:lower:]]+(, [[:lower:]]+)*)*/ {
    aoc::data_error()
}
{
    WEIGHTS[$1] = int($2)
    for (i = 3; i <= NF; ++i) {
        BRANCHES[$1][$i] = 1
        SUPPORTER[$i] = $1
    }
}
END {
    for (b in BRANCHES) {
        if (!(b in SUPPORTER)) {
            print b
        }
    }
}
