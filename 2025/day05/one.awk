#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "-"
    DIVIDER_SEEN = 0
    COUNT = 0
}
$0 !~ /^([[:digit:]]+(-[[:digit:]]+)?)?$/ {
    aoc::data_error()
}
(NF == 1) && !DIVIDER_SEEN {
    aoc::data_error("ingredient in fresh range section")
}
(NF != 1) && DIVIDER_SEEN {
    aoc::data_error("unexpected data in ingredient section")
}
(NF == 2) {
    if (DEBUG) {
        print "range", NR, ":", $1, "-", $2 > DFILE
    }
    if (!($1 in FRESH) || (FRESH[$1] < $2)) {
        FRESH[$1] = $2
    }
}
(NF == 0) {
    DIVIDER_SEEN = 1
}
(NF == 1) {
    if (DEBUG) {
        print "ingredient:", $1 > DFILE
    }
    for (i in FRESH) {
        if (($1 >= (0 + i)) && ($1 <= FRESH[i])) {
            if (DEBUG) {
                print "...FRESH due to range", i, "-", FRESH[i] > DFILE
            }
            ++COUNT
            break
        }
    }
}
END {
    print COUNT
}
