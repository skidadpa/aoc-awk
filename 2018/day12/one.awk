#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function pad_state_as_needed() {
    if (substr(STATE, length(STATE), 1) == "#") {
        STATE = STATE "."
    }
    if (substr(STATE, length(STATE) - 1, 1) == "#") {
        STATE = STATE "."
    }
    if (substr(STATE, length(STATE) - 2, 1) == "#") {
        STATE = STATE "."
    }
    if (substr(STATE, length(STATE) - 3, 1) == "#") {
        STATE = STATE "."
    }
    if (substr(STATE, 1, 1) == "#") {
        --START
        STATE = "." STATE
    }
    if (substr(STATE, 2, 1) == "#") {
        --START
        STATE = "." STATE
    }
    if (substr(STATE, 3, 1) == "#") {
        --START
        STATE = "." STATE
    }
    if (substr(STATE, 4, 1) == "#") {
        --START
        STATE = "." STATE
    }
}
BEGIN {
    FPAT = "[#.]+"
    CODES["."] = 0
    CODES["#"] = 1
    for (c1 in CODES) for (c2 in CODES) for (c3 in CODES) for (c4 in CODES) for (c5 in CODES) {
        RULES[c1 c2 c3 c4 c5] = "."
    }
}
(NR == 1) && ($0 ~ /^initial state: [#.]+$/) {
    START = 0
    STATE = $1
    pad_state_as_needed()
    next
}
(NR == 2) && ($0 ~ /^$/) {
    next
}
(NR > 2) && ($0 ~ /^[#.]{5} => [#.]$/) {
    RULES[$1] = $2
    next
}
{
    aoc::data_error()
}
END {
    if (DEBUG) {
        printf "%3d: %s (start %d)\n", 0, STATE, START
    }
    for (gen = 1; gen <= 20; ++gen) {
        pots = ".."
        for (i = 1; i <= length(STATE) - 4; ++i) {
            pots = pots RULES[substr(STATE, i, 5)]
        }
        STATE = pots ".."
        pad_state_as_needed()
        if (DEBUG) {
            printf "%3d: %s (start %d)\n", gen, STATE, START
        }
    }
    sum = 0
    for (i = 0; i < length(STATE); ++i) {
        if (substr(STATE, i+1, 1) == "#") {
            sum += START + i
        }
    }
    print sum
}
