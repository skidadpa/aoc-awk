#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    COUNT = 0
    DONE = 0
    GRAND_TOTAL = 0
}
/^[ [:digit:]]+$/ && !DONE {
    if (!COUNT) {
        COUNT = NF
    }
    if (COUNT != NF) {
        aoc::data_error("expected " COUNT " fields")
    }
    for (i = 1; i <= NF; ++i) {
        DATA[i][NR] = $i
    }
    next
}
/^[ *+]+$/ && !DONE {
    if (COUNT != NF) {
        aoc::data_error("expected " COUNT " fields")
    }
    for (operator = 1; operator <= NF; ++operator) {
        if (DEBUG) {
            printf("%s ( %d", $operator, DATA[operator][1]) > DFILE
            for (i = 2; i < NR; ++i) {
                printf(", %d", DATA[operator][i]) > DFILE
            }
            printf(") = ") > DFILE
        }
        if ($operator == "+") {
            sum = 0
            for (i = 1; i < NR; ++i) {
                sum += DATA[operator][i]
            }
            GRAND_TOTAL += sum
            if (DEBUG) {
                print sum > DFILE
            }
        } else {
            product = 1
            for (i = 1; i < NR; ++i) {
                product *= DATA[operator][i]
            }
            GRAND_TOTAL += product
            if (DEBUG) {
                print product > DFILE
            }
        }
    }
    DONE = 1
    next
}
{
    aoc::data_error()
}
END {
    print GRAND_TOTAL
}
