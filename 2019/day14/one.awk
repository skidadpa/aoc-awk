#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    FPAT = "[[:alnum:]]+"
}

$0 !~ /^[[:digit:]]+ [[:upper:]]+(, [[:digit:]]+ [[:upper:]]+)* => [[:digit:]]+ [[:upper:]]+$/ { aoc::data_error() }

{
    i = NF
    output = $i
    --i
    if (output in YIELDS) {
        aoc::data_error("duplicate generation rule found for " output)
    }
    YIELDS[output] = $i
    STORES[output] = 0
    while (i > 2) {
        --i
        input = $i
        --i
        FORMULAS[output][input] = $i
    }
    if (DEBUG) {
        sep = ""
        for (input in FORMULAS[output]) {
            printf "%s%d %s", sep, FORMULAS[output][input], input > DFILE
            sep = " & "
        }
        printf " required to produce %d %s\n", YIELDS[output], output > DFILE
    }
}

END {
    if (!("FUEL" in FORMULAS)) {
        aoc::compute_error("no formula for FUEL")
    }
    ore_required = 0
    STEPS[0]["FUEL"] = 1
    step = 0
    while (step in STEPS) {
        if (DEBUG > 1) {
            printf "STEP %d:\n", step > DFILE
        }
        for (material in STEPS[step]) {
            output_needed = STEPS[step][material]
            if (STORES[material] >= output_needed) {
                if (DEBUG > 1) {
                    printf "depleting stores by %d %s, no more needed\n", output_needed, material > DFILE
                }
                STORES[material] -= output_needed
                continue
            }
            if ((DEBUG > 1) && (STORES[material] > 0)) {
                printf "depleting stores by %d %s,", STORES[material], material > DFILE
            }
            output_needed -= STORES[material]
            STORES[material] = 0
            if ((DEBUG > 1) && (STORES[material] > 0)) {
                printf " %d more needed\n", output_needed > DFILE
            }
            multiplier = int(output_needed / YIELDS[material]) + ((output_needed % YIELDS[material]) != 0)
            output_produced = multiplier * YIELDS[material]
            extra_output = output_produced - output_needed
            STORES[material] += extra_output
            if (DEBUG > 1) {
                printf "%d %s", output_produced, material > DFILE
                if (extra_output) {
                    printf " (including %d extra)", extra_output > DFILE
                }
                printf ":" > DFILE
            }
            sep = ""
            for (input in FORMULAS[material]) {
                input_needed = multiplier * FORMULAS[material][input]
                if (DEBUG > 1) {
                    printf "%s %d %s", sep, input_needed, input > DFILE
                    sep = ","
                }
                if (input == "ORE") {
                    ore_required += input_needed
                } else {
                    STEPS[step + 1][input] += input_needed
                }
            }
            if (DEBUG > 1) {
                printf "\n" > DFILE
            }
        }
        ++step
    }
    print ore_required
}
