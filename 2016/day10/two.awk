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
    OUTPUT_CHECKS["output0"] = 1
    OUTPUT_CHECKS["output1"] = 1
    OUTPUT_CHECKS["output2"] = 1
    ROUND_LIMIT = 100
}
(NR == 1) && /^SAMPLE DATA SET$/ {
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
    running = 1
    for (round = 1; running && (round <= ROUND_LIMIT); ++round) {
        split("", DESTINATIONS)
        for (b in RULES) {
            if (!(b in CHIPS) || (length(CHIPS[b]) < 2)) {
                continue
            }
            len = asorti(CHIPS[b], COMPARE, "@val_num_asc")
            if (len != 2) {
                aoc::compute_error(b " has " len " chips")
            }
            DESTINATIONS[RULES[b]["low"]][COMPARE[1]] = CHIPS[b][COMPARE[1]]
            DESTINATIONS[RULES[b]["high"]][COMPARE[2]] = CHIPS[b][COMPARE[2]]
            delete CHIPS[b]
        }
        running = (length(DESTINATIONS) > 0)
        for (b in DESTINATIONS) for (c in DESTINATIONS[b]) {
            CHIPS[b][c] = DESTINATIONS[b][c]
        }
        if (DEBUG) {
            print "after round", round > DFILE
            show_chip_counts()
        }
    }
    product = 1
    for (o in OUTPUT_CHECKS) {
        if (DEBUG) {
            print "checking chips at", o > DFILE
        }
        if ((!o in CHIPS) || (length(CHIPS[o]) != 1)) {
            aoc::compute_error("wrong chip count for " o)
        }
        for (c in CHIPS[o]) {
            product *= c
        }
    }
    print product
}
