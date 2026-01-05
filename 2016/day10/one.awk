#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function show_chip_counts(   b, c) {
    for (b in CHIPS) for (c in CHIPS[b]) {
        print b, "has", CHIPS[b][c], "chip of value", c > DFILE
    }
}
function show_rules(   b) {
    for (b in RULES) {
        print b, "gives low to", RULES[b]["low"], "and high to", RULES[b]["high"] > DFILE
    }
}
BEGIN {
    FPAT = "([[:digit:]]+)|(output)|(bot)"
    COMPARE_CHECKS[17] = 1
    COMPARE_CHECKS[61] = 1
    ROUND_LIMIT = 100
}
(NR == 1) && /^SAMPLE DATA SET$/ {
    delete COMPARE_CHECKS
    COMPARE_CHECKS[2] = 1
    COMPARE_CHECKS[5] = 1
    next
}
/^value [[:digit:]]+ goes to bot [[:digit:]]+$/ {
    if ($1 in VALUES) {
        aoc::data_error("duplicate value " $1)
    }
    ++VALUES[$1]
    ++CHIPS[$2 $3][$1]
    next
}
/^bot [[:digit:]]+ gives low to ((bot)|(output)) [[:digit:]]+ and high to ((bot)|(output)) [[:digit:]]+$/ {
    if ($1 $2 in RULES) {
        aoc::data_error("duplicate rule: " $1 $2 " gives low to " RULES[$1 $2]["low"] " and high to " RULES[$1 $2]["high"])
    }
    RULES[$1 $2]["low"] = $3 $4
    RULES[$1 $2]["high"] = $5 $6
    next
}
{
    aoc::data_error()
}
END {
    if (DEBUG) {
        show_rules()
        print "initially" > DFILE
        show_chip_counts()
    }
    bot = "NONE"
    for (round = 1; (bot == "NONE") && (round <= ROUND_LIMIT); ++round) {
        split("", DESTINATIONS)
        for (b in RULES) {
            if (!(b in CHIPS) || (length(CHIPS[b]) < 2)) {
                continue
            }
            len = asorti(CHIPS[b], COMPARE, "@val_num_asc")
            if (len != 2) {
                aoc::compute_error(b " has " len " chips")
            }
            if ((COMPARE[1] in COMPARE_CHECKS) && (COMPARE[2] in COMPARE_CHECKS)) {
                if (DEBUG) {
                    print "FOUND:", b, "compared", COMPARE[1], "to", COMPARE[2], "in round", round > DFILE
                }
                bot = b
            }
            DESTINATIONS[RULES[b]["low"]][COMPARE[1]] = CHIPS[b][COMPARE[1]]
            DESTINATIONS[RULES[b]["high"]][COMPARE[2]] = CHIPS[b][COMPARE[2]]
            delete CHIPS[b]
        }
        for (b in DESTINATIONS) for (c in DESTINATIONS[b]) {
            CHIPS[b][c] = DESTINATIONS[b][c]
        }
        if (DEBUG) {
            print "after round", round > DFILE
            show_chip_counts()
        }
    }
    print bot
}
