#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FS = ""
    MATCHING_KEY = MATCHING_LOCK = 0
    PATTERN = "^[#.]{5}$"
    HEIGHT = 5
    NUM_KEYS = NUM_LOCKS = 0
}
$0 !~ PATTERN {
    aoc::data_error()
}
{
    if (!MATCHING_KEY && !MATCHING_LOCK)
    {
        if ($0 == ".....") {
            MATCHING_KEY = 1
            ++NUM_KEYS
        } else if ($0 == "#####") {
            MATCHING_LOCK = 1
            ++NUM_LOCKS
        } else {
            if (PATTERN != "^$") {
                aoc::data_error()
            }
            PATTERN = "^[#.]{5}$"
            next
        }
    }
    if (MATCHING_KEY) {
        for (i = 1; i <= NF; ++i) {
            if ($i == ".") {
                KEYS[NUM_KEYS][i] = HEIGHT
            }
        }
    } else if (MATCHING_LOCK) {
        for (i = 1; i <= NF; ++i) {
            if ($i == "#") {
                LOCKS[NUM_LOCKS][i] = HEIGHT
            }
        }
    } else {
        aoc::data_error("not matching anything")
    }
    if (HEIGHT-- < 0) {
        MATCHING_KEY = MATCHING_LOCK = 0
        PATTERN = "^$"
        HEIGHT = 5
    }
}
END {
    if (DEBUG) {
        for (i in KEYS) {
            printf("key %d:", i)
            separator = " "
            for (j in KEYS[i]) {
                printf("%s%d", separator, KEYS[i][j])
                separator = ","
            }
            printf("\n")
        }
        for (i in LOCKS) {
            printf("lock %d:", i)
            separator = " "
            for (j in LOCKS[i]) {
                printf("%s%d", separator, LOCKS[i][j])
                separator = ","
            }
            printf("\n")
        }
    }
    for (k in KEYS) {
        if (DEBUG) {
            print "Checking key", k
        }
        for (l in LOCKS) {
            for (i = 1; i <= 5; ++i) {
                if (KEYS[k][i] > LOCKS[l][i]) {
                    break
                }
            }
            if (i > 5) {
                ++FITS
            }
        }
    }
    print FITS
}
