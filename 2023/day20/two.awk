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
# After some analysis the final state after settling is always the
# initial state, which is a useful (and easily verified) assumption.
#
# If only the HIGH pulse were generated it would be a simple matter to
# find the LCM of all button presses to find out when ALL of SUBGRAPHs
# have sent a HIGH pulse so the final NAND will send a LOW pulse to rx.
#
# In fact, LOW pulses are generated after the HIGH pulses so a complete
# solution should verify that timing is met. However, it is likely that
# the pulses are already generated in compatible periods, since if not,
# getting all of them to line up might be impossible. So for now we will
# stop there.
#
# And that is the case, at least for this data (and apparently others
# are seeing the same thing).
#
@include "../../lib/aoc.awk"
BEGIN {
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
        print "SUBGRAPHS:" > DFILE
        for (g in SUBGRAPHS) {
            printf "%s:", g > DFILE
            for (n in SUBGRAPHS[g]) {
                printf " %s", n > DFILE
            }
            printf "\n" > DFILE
        }
    }

    if (DEBUG) {
        print "INITIAL STATE:" > DFILE
    }
    for (g in SUBGRAPHS) {
        INITIAL_STATES[g] = state(g)
        if (DEBUG) {
            print INITIAL_STATES[g] > DFILE
        }
    }

    if (DEBUG) {
        print "RUNNING EACH SUBGRAPH TO HIGH OUTPUT:" > DFILE
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
            print g, ": after", input_pulses, "input pulses", g, "produced", output_pulses, "output pulses, generating at time:" > DFILE
            zeros = 0
            for (t in FINAL_WRITES) {
                if (!zeros) {
                    print " " t ": zero" > DFILE
                }
                if (FINAL_WRITES[t]) {
                    if (zeros > 1) {
                        print " then", (zeros - 1), "more zeros" > DFILE
                    }
                    print " " t ": one" > DFILE
                    zeros = 0
                } else {
                    ++zeros
                }
            }
            if (zeros > 1) {
                print " then", (zeros - 1), "more zeros" > DFILE
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
            print g, "requires", REQUIRED_PRESSES[g], "input pulses to reach HIGH" > DFILE
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
}
