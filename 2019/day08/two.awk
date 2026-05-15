#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    FS = ""
    BLACK = 0
    WHITE = 1
    TRANSPARENT = 2
    COLOR[BLACK] = " "
    COLOR[WHITE] = "X"
    COLOR[TRANSPARENT] = COLOR[""] = "."
}

$0 !~ /^[012]+$/ { aoc::data_error("expected one line of numbers 0-2") }
NR != 1 { aoc::data_error("expected only one line") }

{
    if (NF == 16) {
        WIDTH = 2
        HEIGHT = 2
    } else {
        WIDTH = 25
        HEIGHT = 6
    }
    LAYER_SIZE = WIDTH * HEIGHT
    LAYER_COUNT = NF / LAYER_SIZE
    if (DEBUG) {
        print LAYER_COUNT, "LAYERS OF SIZE:", LAYER_SIZE > DFILE
    }
    split("", IMAGE)
    for (i = 1; i <= NF; ++i) {
        layer = int((i - 1) / LAYER_SIZE) + 1
        offset = ((i - 1) % LAYER_SIZE) + 1
        if (($i != TRANSPARENT) && !(offset in IMAGE)) {
            IMAGE[offset] = $i
        }
    }
    for (i = 1; i <= LAYER_SIZE; ++i) {
        printf "%s", COLOR[IMAGE[i]]
        if ((i % WIDTH) == 0) {
            printf "\n"
        }
    }
}
