#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    PATTERN = "^[.]+S[.]+$"
    FS = ""
    split("", BEAMS)
    SPLITTER_HITS = 0
}
$0 !~ PATTERN {
    aoc::data_error("expected " PATTERN)
}
{
    if (PATTERN == "^[.]+$") {
        PATTERN = "^[.][.^]+[.]$"
        next
    } else {
        PATTERN = "^[.]+$"
    }
    for (i = 1; i <= NF; ++i) {
        if ($i == "^") {
            if (i in BEAMS) {
                ++SPLITTER_HITS
                delete BEAMS[i]
                BEAMS[i - 1] = BEAMS[i + 1] = 1
            }
        } else if ($i == "S") {
            BEAMS[i] = 1
            next
        }
    }
}
END {
    print SPLITTER_HITS
}
