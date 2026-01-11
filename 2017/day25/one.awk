#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    RS = ""
    FS = "\n"
    EXPECTED_NF = 2
    MOVES["left"] = -1
    MOVES["right"] = 1
}
(NF != EXPECTED_NF) { aoc::data_error("wrong number of lines in section") }
(NR == 1) {
    if (match($1, /^Begin in state ([[:upper:]])[.]$/, m) != 1) {
        aoc::data_error($1 " is not a proper start state definition")
    }
    START_STATE = m[1]
    if (match($2, /^Perform a diagnostic checksum after ([[:digit:]]+) steps[.]$/, m) != 1) {
        aoc::data_error($2 " is not a proper checksum step definition")
    }
    NUM_STEPS = 0 + m[1]
    if (DEBUG) {
        print "START:", START_STATE, "STEPS:", NUM_STEPS > DFILE
    }
    EXPECTED_NF = 9
    next
}
{
    if (match($1, /^In state ([[:upper:]]):$/, m) != 1) {
        aoc::data_error($1 " is not a proper state heading")
    }
    state = m[1]
    if (match($2, /^  If the current value is 0:$/) != 1) {
        aoc::data_error($2 " is not a proper value 0 heading")
    }
    if (match($3, /^    - Write the value ([01])[.]$/, m) != 1) {
        aoc::data_error($3 " is not a proper write value")
    }
    WRITE[state][0] = m[1]
    if (match($4, /^    - Move one slot to the ((left)|(right))[.]$/, m) != 1) {
        aoc::data_error($4 " is not a proper slot move")
    }
    MOVE[state][0] = MOVES[m[1]]
    if (match($5, /^    - Continue with state ([[:upper:]])[.]$/, m) != 1) {
        aoc::data_error($5 " is not a proper state transition")
    }
    NEXT_STATE[state][0] = m[1]
    if (match($6, /^  If the current value is 1:$/) != 1) {
        aoc::data_error($6 " is not a proper value 1 heading")
    }
    if (match($7, /^    - Write the value ([01])[.]$/, m) != 1) {
        aoc::data_error($7 " is not a proper write value")
    }
    WRITE[state][1] = m[1]
    if (match($8, /^    - Move one slot to the ((left)|(right))[.]$/, m) != 1) {
        aoc::data_error($8 " is not a proper slot move")
    }
    MOVE[state][1] = MOVES[m[1]]
    if (match($9, /^    - Continue with state ([[:upper:]])[.]$/, m) != 1) {
        aoc::data_error($5 " is not a proper state transition")
    }
    NEXT_STATE[state][1] = m[1]
}
END {
    state = START_STATE
    pos = 0
    split("", ONES)
    for (step = 1; step <= NUM_STEPS; ++step) {
        value = (pos in ONES)
        if (WRITE[state][value]) {
            ONES[pos] = 1
        } else {
            delete ONES[pos]
        }
        pos += MOVE[state][value]
        state = NEXT_STATE[state][value]
    }
    print length(ONES)
}
