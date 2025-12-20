#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    COUNT = 0
    DONE = 0
    FS = ""
    GRAND_TOTAL = 0
}
/^[ [:digit:]]+$/ && !DONE {
    if (!COUNT) {
        COUNT = NF
    }
    if (COUNT != NF) {
        aoc::data_error("expected " COUNT " width")
    }
    for (i = 1; i <= NF; ++i) {
        DATA[i] = DATA[i] $i
    }
    next
}
/^[ *+]+$/ && !DONE {
    if (COUNT != NF) {
        aoc::data_error("expected " COUNT " width")
    }
    operator = " "
    for (i = 1; i <= NF; ++i) {
        if ($i ~ "[+*]") {
            if (operator != " ") {
                aoc::data_error("did not expect operator, got " $i)
            }
            operator = $i
            sum = 0
            product = 1
            if (DEBUG) {
                print operator, "(" > DFILE
            }
        }
        if (DATA[i] ~ "[[:digit:]]") {
            if (operator == " ") {
                aoc::data_error("got data with no operator " DATA[i])
            }
            if (DEBUG) {
                print "  ", DATA[i] > DFILE
            }
            if (operator == "+") {
                sum += DATA[i]
            } else {
                product *= DATA[i]
            }
        } else {
            if (operator == " ") {
                aoc::data_error("hit end of data with no operator")
            }
            if (operator == "+") {
                if (DEBUG) {
                    print "  ) =", sum > DFILE
                }
                GRAND_TOTAL += sum
            } else {
                if (DEBUG) {
                    print "  ) =", product > DFILE
                }
                GRAND_TOTAL += product
            }
            operator = " "
        }
    }
    if (operator == "+") {
        if (DEBUG) {
            print "  ) =", sum > DFILE
        }
        GRAND_TOTAL += sum
    } else {
        if (DEBUG) {
            print "  ) =", product > DFILE
        }
        GRAND_TOTAL += product
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
