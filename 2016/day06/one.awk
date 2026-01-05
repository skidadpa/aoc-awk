#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="[a-z]"
}
$0 !~ /^[a-z]+$/ {
    aoc::data_error()
}
{
    for (i = 1; i <= NF; ++i) {
        ++FREQ[i][$i]
    }
}
END {
    code = ""
    for (c in FREQ) {
        asorti(FREQ[c], CHAR, "@val_num_desc")
        if (DEBUG) {
            print "CHARACTER", c > DFILE
            for (i in CHAR) {
                print i, CHAR[i], FREQ[c][CHAR[i]] > DFILE
            }
        }
        code = code CHAR[1]
    }
    print code
}
