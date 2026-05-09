#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    COUNT = 0
    FS = "-"
    PDESC[0] = "NO PAIR FOUND"
    PDESC[1] = "PAIR FOUND"
    IDESC[0] = "DECREASED"
    IDESC[1] = "NEVER DECREASED"
}

$0 !~ /^[[:digit:]]{6}-[[:digit:]]{6}$/ { aoc::data_error() }

{
    for (i = $1; i <= $2; ++i) {
        pair_found = 0
        never_increases = 1
        match_length = 1
        last_digit = i % 10
        digits = int(i / 10)
        while (digits) {
            digit = digits % 10
            if (digit > last_digit) {
                never_increases = digits = 0
            } else {
                digits = int(digits/10)
                if (!pair_found) {
                    if (digit == last_digit) {
                        ++match_length
                    } else {
                        pair_found = (match_length == 2)
                        match_length = 1
                    }
                }
            }
            last_matched = (digit == last_digit)
            last_digit = digit
        }
        pair_found = pair_found || (match_length == 2)
        if (DEBUG > 1) {
            printf "%d: %s, %s\n", i, PDESC[pair_found], IDESC[never_increases] > DFILE
        }
        if (pair_found && never_increases) {
            if (DEBUG) {
                print "match found at", i > DFILE
            }
            ++COUNT
        }
    }
}

END {
    print COUNT
}
