#!/usr/bin/env gawk -f
#
# The overall graph looks like this:
#
#                            /--> SUBGRAPH --\
#                           /                 \
#                          +----> SUBGRAPH --\ \
#                         /                   v v
# button -> broadcaster -+                    NAND -> rx
#                         \                   ^ ^
#                          +----> SUBGRAPH --/ /
#                           \                 /
#                            \--> SUBGRAPH --/
#
# And each SUBGRAPH looks like this:
#
# --> FLOP <--------------------------------------> NAND --> INVERTER -->
#         \                                        / ^
#          \               /----------------------/  |
#           \              |            /------------/
#            \             v            |
#             +--> BUNCH OF FLOPS INTERCONNECTED TO NAND
#
# Thus the key is to find out how many input pulses are needed to get
# the INVERTERs at the end of each SUBGRAPH to yield a HIGH pulse.
#
# If that were the only pulse generated then it would be a simple matter
# to find the LCM of all button presses to find out when ALL of SUBGRAPHs
# have sent a HIGH pulse so the final NAND will send a LOW pulse to rx.
#
# In fact, LOW pulses are generated after the HIGH pulses so a complete
# solution should verify that timing is met. However, it is likely that
# the pulses are already generated in compatible periods, since if not,
# getting all of them to line up might be impossible. So for now we will
# stop there.
#
# After some analysis the final state after settling is always the
# initial state, which improves the likelihood of LCM being sufficient.
#
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 2
    FPAT="[a-z]+"
    LOW = 0
    HIGH = 1
    PROCINFO["sorted_in"] = "@ind_num_asc"
}
/^&[a-z]+ -> rx$/ {
    if (rx_driver) {
        aoc::compute_error("must be exactly one rx driver")
    }
    rx_driver = $1
}
/^broadcaster -> [a-z]+(, [a-z]+)*$/ {
    KINDS[$1] = $1
}
/^%[a-z]+ -> [a-z]+(, [a-z]+)*$/ {
    KINDS[$1] = "FF"
}
/^&[a-z]+ -> [a-z]+(, [a-z]+)*$/ {
    KINDS[$1] = "NAND"
}
/^(broadcaster)|([&%][a-z]+) -> [a-z]+(, [a-z]+)*$/ {
    VALUES[$1] = LOW
    for (i = 2; i <= NF; ++i) {
        TARGETS[$1][i - 1] = $i
        INPUTS[$i][$1] = LOW
        SRCS[$i][$1] = 1
        DSTS[$1][$i] = 1
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
    for (s in INPUTS[dest]) {
        if (INPUTS[dest][s] != HIGH) {
            return HIGH
        }
    }
    return LOW
}
function state(g,   s, n, sep, i) {
    s = g ":"
    sep = ""
    for (n in SUBGRAPHS[g]) {
        switch (KINDS[n]) {
        case "FF":
            s = s sep n "=" VALUES[n]
            sep = " "
            break
        case "NAND":
            s = s sep n "="
            sep = ""
            for (i in INPUTS[n]) {
                s = s sep i "+" INPUTS[n][i]
                sep = ","
            }
            sep = " "
            break
        case "INV":
            # inverters don't care about state
            break
        case "broadcaster":
        case "RX":
        case "": # target with no rule
        default:
            # shouldn't find any of these in a subgraph...
            aoc::compute_error("unexpected kind " KINDS[n])
        }
    }
    return s
}
function restore(state,   s, g, nodes, n, v, ivals, i, ival) {
    if (split(state, s, ":") != 2) {
        aoc::compute_error("illegal state " s)
    }
    g = s[1]
    if (DEBUG) {
        print "restoring state of subgraph", g > DFILE
    }
    split(s[2], nodes)
    for (n in nodes) {
        if (split(nodes[n], v, "=") != 2) {
            aoc::compute_error("illegal initializer " nodes[n])
        }
        if (!(v[1] in SUBGRAPHS[g])) {
            aoc::compute_error("restore node " n " not in subgraph " g)
        }
        switch (KINDS[v[1]]) {
        case "FF":
            VALUES[v[1]] = v[2]
            break
        case "NAND":
            split(v[2], ivals, ",")
            for (i in ivals) {
                if (split(ivals[i], ival, "+") != 2) {
                    aoc::compute_error("illegal input initializer " ival)
                }
                INPUTS[v[1]][ival[1]] = ival[2]
            }
            break
        case "INV":
        case "broadcaster":
        case "RX":
        case "": # target with no rule
        default:
            # shouldn't find any of these in restore data
            aoc::compute_error("unexpected restore to " v[1] " of type " KINDS[v[1]])
        }
    }
}
END {
    for (n in KINDS) {
        if ((KINDS[n] == "NAND") && (length(SRCS[n]) == 1)) {
            if (DEBUG > 3) {
                print "converting", n, "into INV" > DFILE
            }
            KINDS[n] = "INV"
        }
    }
    KINDS["rx"] = "RX"
    # check assumptions, start building tables
    if (length(SRCS["rx"]) != 1) {
        aoc::compute_error("expect one NAND driving rx")
    }
    for (n in SRCS["rx"]) {
        FINAL_NODE = n
        if (DEBUG) {
            print "FINAL NODE:", n > DFILE
        }
        break
    }
    if (KINDS[FINAL_NODE] != "NAND") {
        aoc::compute_error("expect one NAND driving rx")
    }
    for (i in SRCS[FINAL_NODE]) {
        # check is not technically necessary...
        if (KINDS[i] != "INV") {
            aoc::compute_error("expect INV at end of SUBGRAPH, saw " KINDS[i] " at " i)
        }
    }
    for (n in DSTS["broadcaster"]) {
        SUBGRAPHS[n][n] = 1
    }
    for (g in SUBGRAPHS) {
        split("", PASSES)
        pass = 1
        PASSES[pass][g] = 1
        while (pass in PASSES) {
            for (i in PASSES[pass]) {
                for (o in DSTS[i]) {
                    if ((o == FINAL_NODE) || (o in SUBGRAPHS[g])) {
                        continue
                    }
                    PASSES[pass + 1][o] = 1
                    SUBGRAPHS[g][o] = 1
                }
            }
            delete PASSES[pass]
            ++pass
        }
    }
    if (DEBUG) {
        print "SUBGRAPHS:"
        for (g in SUBGRAPHS) {
            printf "%s:", g > DFILE
            for (n in SUBGRAPHS[g]) {
                printf " %s", n > DFILE
            }
            printf "\n" > DFILE
        }
    }

    if (DEBUG) {
        print "INITIAL STATE:"
    }
    for (g in SUBGRAPHS) {
        INITIAL_STATES[g] = state(g)
        if (DEBUG) {
            print INITIAL_STATES[g]
        }
    }

    if (DEBUG) {
        print "RUNNING EACH SUBGRAPH TO HIGH OUTPUT:"
    }
    most_input_pulses_needed = 0
    for (g in SUBGRAPHS) {
        split("", FINAL_WRITES)
        input_pulses = 0
        output_pulses = 0
        emitted_high_pulse = 0

        last_state = INITIAL_STATES[g]
        #
        # need to repeat the following until a high pulse is generated:
        #
        while (!emitted_high_pulse) {
            ++input_pulses
            split("", DESTS)
            split("", PULSES)
            split("", SENDERS)
            p = 1
            DESTS[p] = g
            PULSES[p] = LOW
            SENDERS[p] = "broadcaster"
            nextp = 2
            while (p < nextp) {
                if (DESTS[p] == FINAL_NODE) {
                    FINAL_WRITES[output_pulses + p] = PULSES[p]
                    if (PULSES[p] == HIGH) {
                        emitted_high_pulse = 1
                    }
                } else {
                    switch (KINDS[DESTS[p]]) {
                    case "FF":
                        if (PULSES[p] == LOW) {
                            v = !VALUES[DESTS[p]]
                            VALUES[DESTS[p]] = v
                            for (t in TARGETS[DESTS[p]]) {
                                DESTS[nextp] = TARGETS[DESTS[p]][t]
                                PULSES[nextp] = v
                                SENDERS[nextp] = DESTS[p]
                                ++nextp
                            }
                        }
                        break
                    case "NAND":
                        INPUTS[DESTS[p]][SENDERS[p]] = PULSES[p]
                        v = nand_level(DESTS[p])
                        for (t in TARGETS[DESTS[p]]) {
                            DESTS[nextp] = TARGETS[DESTS[p]][t]
                            PULSES[nextp] = v
                            SENDERS[nextp] = DESTS[p]
                            ++nextp
                        }
                        break
                    case "INV":
                        v = !PULSES[p]
                        for (t in TARGETS[DESTS[p]]) {
                            DESTS[nextp] = TARGETS[DESTS[p]][t]
                            PULSES[nextp] = v
                            SENDERS[nextp] = DESTS[p]
                            ++nextp
                        }
                        break
                    case "RX":
                    case "broadcaster":
                    case "": # target with no rule
                    default:
                        aoc::compute_error(DESTS[p] " unexpected kind " KINDS[DESTS[p]])
                    }
                }
                delete DESTS[p]
                delete PULSES[p]
                delete SENDERS[p]
                ++p
            }
            output_pulses += p - 1
            current_state = state(g)
            if (!emitted_high_pulse && (current_state == INITIAL_STATES[g])) {
                aoc::compute_error(g " returned to initial state with no HIGH output")
            }
            if (!emitted_high_pulse && (current_state == last_state)) {
                aoc::compute_error(g " state unchanged with no HIGH output")
            }
            last_state = current_state
        }
        if (DEBUG > 1) {
            print g, ": after", input_pulses, "input pulses", g, "produced", output_pulses, "output pulses, generating at time:"
            zeros = 0
            for (t in FINAL_WRITES) {
                if (!zeros) {
                    print " " t ": zero"
                }
                if (FINAL_WRITES[t]) {
                    if (zeros > 1) {
                        print " then", (zeros - 1), "more zeros"
                    }
                    print " " t ": one"
                    zeros = 0
                } else {
                    ++zeros
                }
            }
            if (zeros > 1) {
                print " then", (zeros - 1), "more zeros"
            }
        }
        if (current_state != INITIAL_STATES[g]) {
            aoc::compute_error(g " does not return to initial state")
        }
        REQUIRED_PRESSES[g] = input_pulses
        if (most_input_pulses_needed < input_pulses) {
            most_input_pulses_needed = input_pulses
        }
    }
    if (DEBUG) {
        for (g in SUBGRAPHS) {
            print g, "requires", REQUIRED_PRESSES[g], "input pulses to reach HIGH"
        }
    }
    
    # calculate prime factor candidates
    PRIMES[2] = 1
    limit = sqrt(most_input_pulses_needed)
    for (i = 3; i <= limit; i += 2) {
        prime = 1
        for (f in PRIMES) {
            if ((i % f) == 0) {
                prime = 0
                break
            }
        }
        if (prime) {
            PRIMES[i] = 1
        }
    }
    split("", ALL_FACTORS)
    for (g in REQUIRED_PRESSES) {
        target = REQUIRED_PRESSES[g]
        split("", FACTORS)
        for (p in PRIMES) {
            while ((target % p) == 0) {
                ++FACTORS[p]
                target /= p
            }
        }
        if (target > 1) {
            FACTORS[target] = 1
        }
        for (f in FACTORS) {
            if ((0 + ALL_FACTORS[f]) < FACTORS[f]) {
                ALL_FACTORS[f] = FACTORS[f]
            }
        }
    }
    lcm = 1
    for (f in ALL_FACTORS) {
        lcm *= (0 + f) * ALL_FACTORS[f]
    }
    print lcm

    exit
    num_pulses = 0
    current_pulse = 1
    split("", sources)
    split("", destinations)
    split("", levels)
    split("", pulses_sent)
    last_pulse = 0
    PROCINFO["sorted_in"] = "@ind_num_asc"
    product = 1

    if (!rx_driver) {
        aoc::compute_error("must be exactly one rx driver")
    }
    for (i in INPUTS[rx_driver]) {
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
            kind = KINDS[dest]
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
                    for (target in TARGETS[dest]) {
                        send(LOW, dest, TARGETS[dest][target])
                    }
                    break
                case "FF":
                    if (level == LOW) {
                        value = !VALUES[dest]
                        VALUES[dest] = value
                        for (target in TARGETS[dest]) {
                            send(value, dest, TARGETS[dest][target])
                        }
                    }
                    break
                case "NAND":
                case "INV":
                    INPUTS[dest][source] = level
                    value = nand_level(dest)
                    for (target in TARGETS[dest]) {
                        send(value, dest, TARGETS[dest][target])
                    }
                    break
                case "RX":
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
        for (source in INPUTS[rx_driver]) {
            if ((source in looking_for) && (INPUTS[rx_driver][source] == HIGH)) {
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
