#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 1
    FPAT="[a-z]+"
    LOW = 0
    HIGH = 1
}
/^&[a-z]+ -> rx$/ {
    if (rx_driver) {
        aoc::compute_error("must be exactly one rx driver")
    }
    rx_driver = $1
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
    if (DEBUG > 2) {
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
    print "NOT IMPLEMENTED YET"
    exit
    num_pulses = 0
    current_pulse = 1
    split("", sources)
    split("", destinations)
    split("", levels)
    split("", pulses_sent)
    last_pulse = 0
    PROCINFO["sorted_in"] = "@ind_num_asc"
    kinds["rx"] = "ON"
    product = 1

    if (!rx_driver) {
        aoc::compute_error("must be exactly one rx driver")
    }
    for (i in inputs[rx_driver]) {
        looking_for[i] = 1
    }

    for (presses = 1; presses <= 1000000; ++presses) {
        if (DEBUG > 2) {
            print "PUSH button"
        }
        send(LOW, "button", "broadcaster")
        while (current_pulse <= last_pulse) {
            source = sources[current_pulse]
            dest = destinations[current_pulse]
            level = levels[current_pulse]
            kind = kinds[dest]
            # if ((dest in looking_for) && (level == HIGH)) {
            #     if (DEBUG) {
            #         print "PULSED", dest, "HIGH AFTER", current_pulse, "PULSES"
            #     }
                # product *= current_pulse
                # delete looking_for[dest]
                # if (length(looking_for) == 0) {
                #     print product
                #     exit
                # }
            # }
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
                case "ON":
                    if (level == LOW) {
                        print presses
                        exit
                    }
                    break
                default:
                    aoc::compute_error("unrecognized kind " kind)
                    break
            }
            delete sources[current_pulse]
            delete destinations[current_pulse]
            delete levels[current_pulse]
            ++current_pulse
        }
        for (source in inputs[rx_driver]) {
            if ((source in looking_for) && (inputs[rx_driver][source] == HIGH)) {
                if (DEBUG) {
                    print source, "HIGH AFTER", presses, "PRESSES"
                }
                product *= presses
                delete looking_for[source]
                if (length(looking_for) == 0) {
                    print product
                    exit
                }
            }
        }
    }

    print "PROCESSING ERROR, rx NOT SEEN AFTER", presses - 1, "BUTTON PRESSES"
}
