#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FS = "," }
(NF != 0 && NF != 2) { aoc::data_error() }
(NF == 0 && FS != ",") { aoc::data_error() }
(NF == 0) { FS = "="; next }
(FS == ",") { paper[$1][$2] = "#" }
(FS == "=") {
    if (already_folded) next; else already_folded = 1
    if ($1 == "fold along x") {
        for (x in paper) {
            if (x+0 > $2+0) {
                for (y in paper[x]) paper[$2 - (x - $2)][y] = paper[x][y]
                delete paper[x]
            } else if (x == $2) { aoc::data_error() }
        }
    } else if ($1 == "fold along y") {
        for (x in paper) {
            for (y in paper[x]) {
                if (y+0 > $2+0) {
                    paper[x][$2 - (y - $2)] = paper[x][y]
                    delete paper[x][y]
                } else if (y == $2) { aoc::data_error() }
            }
        }
    } else { aoc::data_error() }
}
END {
    for (x in paper) size += length(paper[x])
    print size
}
