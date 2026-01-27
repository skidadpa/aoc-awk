#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
    split("", EVENTS)
}
/^\[[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2}\] Guard #[[:digit:]]+ begins shift$/ {
    EVENTS[$2 $3 $4 $5] = $6
    next
}
/^\[[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2}\] falls asleep$/ {
    EVENTS[$2 $3 $4 $5] = "SLEEP"
    next
}
/^\[[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2}\] wakes up$/ {
    EVENTS[$2 $3 $4 $5] = "WAKE"
    next
}
{ aoc::data_error() }
END {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    sleep_start = -1
    guard = -1
    for (t in EVENTS) {
        if (DEBUG) {
            printf "%-8s: %s\n", t, EVENTS[t] > DFILE
        }
        event = EVENTS[t]
        minute = int(substr(t, 7))
        if (event == "SLEEP") {
            if (sleep_start != -1) {
                aoc::compute_error("at " t ", guard must be awake to fall asleep")
            }
            sleep_start = minute
        } else if (event == "WAKE") {
            if (sleep_start == -1) {
                aoc::compute_error("at " t ", guard must be asleep to wake up")
            }
            for (i = sleep_start; i < minute; ++i) {
                ++TOTAL_MINUTES[guard]
                ++MINUTES[guard][i]
            }
            sleep_start = -1
        } else {
            if (sleep_start > -1) {
                for (i = sleep_start; i < 60; ++i) {
                    ++TOTAL_MINUTES[guard]
                    ++MINUTES[guard][i]
                }
                sleep_start = -1
            }
            guard = event
        }
    }
    if (sleep_start > -1) {
        for (i = sleep_start; i < 60; ++i) {
            ++TOTAL_MINUTES[guard]
            ++MINUTES[guard][i]
        }
        sleep_start = -1
    }
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (guard in TOTAL_MINUTES) {
        for (minute in MINUTES[guard]) {
            print guard * minute
            exit
        }
    }
    aoc::compute_error("no sleeping guards found")
}
