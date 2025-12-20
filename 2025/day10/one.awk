#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "([[][.#]+])|([(][[:digit:]]+(,[[:digit:]]+)*[)])|([{][[:digit:]]+(,[[:digit:]]+)*[}])"
    MAX_PRESSES = 1000
    SUM = 0
}
$0 !~ /^\[[.#]+\]( [(][[:digit:]]+(,[[:digit:]]+)*[)])+ [{][[:digit:]]+(,[[:digit:]]+)*[}]$/ {
    aoc::data_error()
}
{
    target = 0
    bit = 1
    for (i = 2; i <= length($1) - 1; ++i) {
        if (substr($1,i,1) == "#") {
            target += bit
        }
        bit = lshift(bit,1)
    }

    split("", BUTTONS)
    for (f = 2; f < NF; ++f) {
        split(substr($f,2,length($f)-2), current_button, ",")
        value = 0
        for (b in current_button) {
            value += lshift(1,current_button[b])
        }
        BUTTONS[value] = value
    }
    if (DEBUG) {
        printf "%d: target %03X, buttons:", NR, target > DFILE
        for (b in BUTTONS) {
            printf " %03X", b > DFILE
        }
        printf "\n" > DFILE
    }
    split("", VALUES)
    split("", SEEN)
    VALUES[0][0] = 1
    SEEN[0] = 1
    for (press = 0; press < MAX_PRESSES; ++press) {
        for (v in VALUES[press]) {
            for (b in BUTTONS) {
                n = xor(v, b)
                if (n == target) {
                    if (DEBUG) {
                        print press + 1, "presses needed" > DFILE
                    }
                    SUM += press + 1
                    next
                }
                if (!(n in SEEN)) {
                    VALUES[press + 1][n] = 1
                    SEEN[n] = 1
                }
            }
        }
    }
    aoc::compute_error("did not find a match after " MAX_PRESSES " presses")
}
END {
    print SUM
}
