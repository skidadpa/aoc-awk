#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="([a-z]+)|([[:digit:]]+)"
    sum = 0
    split("bcdefghijklmnopqrstuvwxyz", CHR, "")
    CHR[0] = "a"
    for (i in CHR) {
        VAL[CHR[i]] = i
    }
    if (DEBUG > 2) {
        print "CHR:" > DFILE
        for (i in CHR) {
            print " ", i, CHR[i] > DFILE
        }
        print "VAL:" > DFILE
        for (ch in VAL) {
            print " ", ch, VAL[ch] > DFILE
        }
    }
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
    gsub(/-[[:digit:]]+\[([a-z]){5}\]$/, "")
    plaintext = ""
    split($0, CHARS, "")
    for (i in CHARS) {
        if (CHARS[i] == "-") {
            plaintext = plaintext " "
            if (DEBUG > 2) {
                print "- becomes SPACE" > DFILE
            }
        } else {
            plaintext = plaintext CHR[(VAL[CHARS[i]] + sector_id) % 26]
            if (DEBUG > 2) {
                print VAL[CHARS[i]], CHARS[i], "becomes", (VAL[CHARS[i]] + sector_id) % 26, CHR[(VAL[CHARS[i]] + sector_id) % 26] > DFILE
            }
        }
    }
    if (match(plaintext, /north *pole/)) {
        if (DEBUG) {
            print sector_id, plaintext > DFILE
        }
        print sector_id
    }
}
