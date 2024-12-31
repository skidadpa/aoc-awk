#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ", "
    POSSIBLE = 0
}
(NR == 1) && ($0 !~ /^[wubrg]+(, [wubrg]+)*$/) {
    aoc::data_error("unrecognized pattern")
}
(NR == 1) {
    PATTERN = "^((" $i ")"
    for (i = 1; i <= NF; ++i) {
        PATTERN = PATTERN "|(" $i ")"
    }
    PATTERN = PATTERN ")+$"
}
(NR == 2) && ($0 !~ /^$/) {
    aoc::data_error("expecting blank line")
}
(NR > 2) && ($0 !~ /^[wubrg]+$/) {
    aoc::data_error("unrecognized pattern")
}
(NR > 2) && ($0 ~ PATTERN) {
    ++POSSIBLE
}
END {
    print POSSIBLE
}
