#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    FS = ""
}

$0 !~ /^[012]+$/ { aoc::data_error("expected one line of numbers 0-2") }
NR != 1 { aoc::data_error("expected only one line") }

{
    WIDTH = 25
    HEIGHT = 6
    LAYER_SIZE = WIDTH * HEIGHT
    LAYER_COUNT = NF / LAYER_SIZE
    if (DEBUG) {
        print LAYER_COUNT, "LAYERS OF SIZE:", LAYER_SIZE > DFILE
    }
    for (i = 1; i <= NF; ++i) {
        layer = int((i - 1) / LAYER_SIZE) + 1
        if ($i == 0) {
            ++ZEROS[layer]
        } else if ($i == 1) {
            ++ONES[layer]
        } else if ($i == 2) {
            ++TWOS[layer]
        } else {
            aoc::compute_error("illegal data value " $i)
        }
    }

    PROCINFO["sorted_in"] = "@val_num_asc"

    for (layer in ZEROS) {
        if (DEBUG) {
            print "LAYER", layer, "HAS", ZEROS[layer], "ZEROS", ONES[layer], "ONES and", TWOS[layer], "TWOS" > DFILE
        }
        print ONES[layer] * TWOS[layer]
        break
    }
}
