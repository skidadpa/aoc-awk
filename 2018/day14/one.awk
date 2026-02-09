#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function add_recipe(   sum, new_recipe, i) {
    sum = RECIPE[e1] + RECIPE[e2]
    new_recipe = "" sum
    for (i = 1; i <= length(new_recipe); ++i) {
        RECIPE[NUM_RECIPES++] = int(substr(new_recipe,i,1))
    }
    e1 = (e1 + RECIPE[e1] + 1) % NUM_RECIPES
    e2 = (e2 + RECIPE[e2] + 1) % NUM_RECIPES
}
BEGIN {
    e1 = 0
    e2 = 1
    RECIPE[e1] = 3
    RECIPE[e2] = 7
    NUM_RECIPES = 2
}
$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }
{
    while (NUM_RECIPES < ($1 + 10)) {
        add_recipe()
    }
    for (i = $1; i < $1 + 10; ++i) {
        printf "%d", RECIPE[i]
    }
    printf "\n"
}
