#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
    XPOS = "none"
    YPOS = 1
    DX = 0
    DY = 1
    split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", temp)
    for (t in temp) {
        LETTERS[temp[t]] = 1
    }
    WIDTH = 0
    LIMIT = 999999
}
(NR == 1) {
    for (x = 1; x <= NF; ++x) {
        if ($x == "|") {
            XPOS = x
        }
    }
    if (POS == "none") {
        aoc::data_error("no entry point found")
    }
}
{
    for (x = 1; x <= NF; ++x) {
        MAP[x,NR] = $x
    }
    if (WIDTH < NF) {
        WIDTH = NF
    }
}
END {
    SEEN = ""
    while ((DX || DY) && (++COUNT <= 999999)) {
        if (DEBUG) {
            for (y = 1; y <= NR; ++y) {
                for (x = 1; x <= WIDTH; ++x) {
                    if ((x == XPOS) && (y == YPOS)) {
                        printf "#" > DFILE
                    } else {
                        printf "%s", MAP[x,y] > DFILE
                    }
                }
                printf "\n" > DFILE
            }
        }
        XPOS += DX
        YPOS += DY
        found = MAP[XPOS, YPOS]
        if (found == "+") {
            if (DY) {
                DY = 0
                if ((MAP[XPOS + 1, YPOS] == "-") || (MAP[XPOS + 1, YPOS] in LETTERS)) {
                    DX = 1
                } else if ((MAP[XPOS - 1, YPOS] == "-") || (MAP[XPOS - 1, YPOS] in LETTERS)) {
                    DX = -1
                }
            } else if (DX) {
                DX = 0
                if ((MAP[XPOS, YPOS + 1] == "|") || (MAP[XPOS, YPOS + 1] in LETTERS)) {
                    DY = 1
                } else if ((MAP[XPOS, YPOS - 1] == "|") || (MAP[XPOS, YPOS - 1] in LETTERS)) {
                    DY = -1
                }
            }
        } else if (found == " ") {
            DX = DY = 0
        } else if (found in LETTERS) {
            SEEN = SEEN found
        }
    }
    if (COUNT > LIMIT) {
        aoc::compute_error("no solution after " COUNT " steps")
    }
    print SEEN
}
