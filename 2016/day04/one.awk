#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="([a-z]+)|([[:digit:]]+)"
    sum = 0
}
$0 !~ /^([a-z]+-)+[[:digit:]]+\[[a-z]{5}\]$/ {
    aoc::data_error()
}
function char_count_compare(i1, v1, i2, v2,   x) {
    if (v1 > v2) {
        return -1
    } else if (v1 < v2) {
        return 1
    } else if (i1 < i2) {
        return -1
    } else if (i1 > i2) {
        return 1
    } else {
        return 0
    }
}
{
    name = ""
    for (i = 1; i <= NF - 2; ++i) {
        name = name $i
    }
    sector_id = $i
    checksum = $NF
    split("", COUNTS)
    split(name, CHARS, "")
    for (ch in CHARS) {
        ++COUNTS[CHARS[ch]]
    }
    asorti(COUNTS, CHECKS, "char_count_compare")
    split(checksum, CHARS, "")
    if (DEBUG > 1) {
        print name, "COUNTS:" > DFILE
        for (i in COUNTS) {
            print " ", i, COUNTS[i] > DFILE
        }
        print name, "CHECKS:" > DFILE
        for (i in CHECKS) {
            print " ", i, CHECKS[i] > DFILE
        }
        print checksum, "CHARS:" > DFILE
        for (i in CHARS) {
            print " ", i, CHARS[i] > DFILE
        }
    }
    for (i in CHARS) {
        if (CHARS[i] != CHECKS[i]) {
            if (DEBUG) {
                print name, sector_id, checksum, "FAILED" > DFILE
            }
            next
        }
    }
    sum += sector_id
    if (DEBUG) {
        print name, sector_id, checksum, "PASSED" > DFILE
    }
}
END {
    print sum
}
