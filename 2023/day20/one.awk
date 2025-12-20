#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FPAT="[a-z]+"
    LOW = 0
    HIGH = 1
}
/^broadcaster -> [a-z]+(, [a-z]+)*$/ {
    kinds[$1] = $1
}
/^%[a-z]+ -> [a-z]+(, [a-z]+)*$/ {
    kinds[$1] = "FF"
}
/^&[a-z]+ -> [a-z]+(, [a-z]+)*$/ {
    kinds[$1] = "NAND"
}
/^(broadcaster)|([&%][a-z]+) -> [a-z]+(, [a-z]+)*$/ {
    pulses[$1] = 0
    values[$1] = LOW
    for (i = 2; i <= NF; ++i) {
        targets[$1][i - 1] = $i
        inputs[$i][$1] = LOW
    }
    next
}
{
    aoc::data_error()
}
function send(level, source, dest) {
    ++pulses_sent[level]
    ++last_pulse
    levels[last_pulse] = level
    sources[last_pulse] = source
    destinations[last_pulse] = dest
    if (DEBUG) {
        printf(" %d: %s %s %s\n", last_pulse, source, level ? "-high->" : "-low->", dest)
    }
}
function nand_level(dest,    s) {
    for (s in inputs[dest]) {
        if (inputs[dest][s] != HIGH) {
            return HIGH
        }
    }
    return LOW
}
END {
    num_pulses = 0
    current_pulse = 1
    split("", sources)
    split("", destinations)
    split("", levels)
    split("", pulses_sent)
    last_pulse = 0
    PROCINFO["sorted_in"] = "@ind_num_asc"

    for (i = 1; i <= 1000; ++i) {
        if (DEBUG) {
            print "PUSH button"
        }
        send(LOW, "button", "broadcaster")
        while (current_pulse <= last_pulse) {
            source = sources[current_pulse]
            dest = destinations[current_pulse]
            level = levels[current_pulse]
            kind = kinds[dest]
            switch (kind) {
                case "": # target with no rule
                    break
                case "broadcaster":
                    for (target in targets[dest]) {
                        send(LOW, dest, targets[dest][target])
                    }
                    break
                case "FF":
                    if (level == LOW) {
                        value = !values[dest]
                        values[dest] = value
                        for (target in targets[dest]) {
                            send(value, dest, targets[dest][target])
                        }
                    }
                    break
                case "NAND":
                    inputs[dest][source] = level
                    value = nand_level(dest)
                    for (target in targets[dest]) {
                        send(value, dest, targets[dest][target])
                    }
                    break
                default:
                    aoc::compute_error("unrecognized kind " kind)
                    break
            }
            ++current_pulse
        }
    }

    if (DEBUG) {
        print last_pulse, "pulses sent"
        print pulses_sent[LOW], "LOW pulses"
        print pulses_sent[HIGH], "HIGH pulses"
    }
    print pulses_sent[LOW] * pulses_sent[HIGH]
}
