#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function add_recipe(   sum, new_recipe, i) {
    sum = int(RECIPE[e1]) + int(RECIPE[e2])
    new_recipe = "" sum
    for (i = 1; i <= length(new_recipe); ++i) {
        RECIPE[NUM_RECIPES++] = substr(new_recipe,i,1)
    }
    e1 = (e1 + RECIPE[e1] + 1) % NUM_RECIPES
    e2 = (e2 + RECIPE[e2] + 1) % NUM_RECIPES
}
BEGIN {
    e1 = 0
    e2 = 1
    RECIPE[e1] = "3"
    RECIPE[e2] = "7"
    NUM_RECIPES = 2
}
$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }
{
    pos = 1
    val = "" $1
    need = length(val)
    i = -1
    if (DEBUG) {
        print "matching", val > DFILE
    }
    while (pos <= need) {
        if (++i >= NUM_RECIPES) {
            add_recipe()
            if (DEBUG > 10) {
                for (r = 0; r < NUM_RECIPES; ++r) {
                    printf "%d", RECIPE[r] > DFILE
                }
                printf "\n" > DFILE
            }
        }
        if (DEBUG > 2) {
            printf "%d (%d): ", i, RECIPE[i]
        }
        if (RECIPE[i] == substr(val, pos, 1)) {
            if (DEBUG > 2) {
                printf "matched %d", substr(val, pos, 1)
            }
            ++pos
            if (pos > need) {
                if (DEBUG) {
                    printf " FOUND\n" > DFILE
                }
                if (DEBUG > 9) {
                    for (r = 0; r < NUM_RECIPES; ++r) {
                        printf "%d", RECIPE[r] > DFILE
                    }
                    printf "\n" > DFILE
                }
                break
            }
        } else if (RECIPE[i] == substr(val, 1, 1)) {
            if (DEBUG > 2) {
                printf "matched start" > DFILE
            }
            pos = 2
        } else if ((pos > 1) && (RECIPE[i] == substr(val, 2, 1)) && (substr(val, pos - 1, 1) == substr(val, 1, 1))) {
            if (DEBUG > 2) {
                printf "matched first two" > DFILE
            }
            pos = 3
        } else {
            if (DEBUG > 2) {
                printf "unmatched" > DFILE
            }
            pos = 1
        }
        if (DEBUG > 2) {
            printf " pos = %d (%d)\n", pos, substr(val, pos, 1) > DFILE
        }
    }
    print i + 1 - need
}
