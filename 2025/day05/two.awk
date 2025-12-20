#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "-"
    DIVIDER_SEEN = 0
}
$0 !~ /^([[:digit:]]+(-[[:digit:]]+)?)?$/ {
    aoc::data_error()
}
(NF == 1) && !DIVIDER_SEEN {
    aoc::data_error("ingredient found in fresh range section")
}
(NF != 1) && DIVIDER_SEEN {
    aoc::data_error("unexpected data in ingredient section")
}
(NF == 2) {
    if (DEBUG) {
        print "range", NR, ":", $1, "-", $2 > DFILE
    }
    split("", overlaps)
    min = 0 + $1
    max = 0 + $2
    for (i in FRESH) {
        if (((min >= (0 + i)) && (min <= FRESH[i])) || \
            ((max >= (0 + i)) && (max <= FRESH[i])) || \
            ((min < (0 + i)) && (max > FRESH[i]))) {
            overlaps[i] = FRESH[i]
            if (DEBUG) {
                print "...overlaps range", i, "-", FRESH[i] > DFILE
            }
        }
    }
    for (i in overlaps) {
        if ((0 + i) < min) {
            min = 0 + i
        }
        if (overlaps[i] > max) {
            max = overlaps[i]
        }
        delete FRESH[i]
    }
    FRESH[min] = max
}
(NF == 0) {
    DIVIDER_SEEN = 1
}
END {
    if (DEBUG) {
        print "UPDATED RANGES:" > DFILE
        for (i in FRESH) {
            print " ", i, "-", FRESH[i] > DFILE
        }
    }
    sum = 0
    for (i in FRESH) {
        sum += 1 + FRESH[i] - i
    }
    print sum
}
