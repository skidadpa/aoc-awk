#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("ABCDEFGHIJKLMNOPQRSTUVWYXZ", STEP_NAMES, "")
    for (i in STEP_NAMES) {
        COST[STEP_NAMES[i]] = i
    }
}
$0 !~ /^Step [[:upper:]] must be finished before step [[:upper:]] can begin[.]$/ { aoc::data_error() }
{
    ACTIVATES[$2][$8] = 1
    DEPENDS_ON[$8][$2] = 1
}
END {
    if (NR > 10) {
        for (step in COST) {
            COST[step] += 60
        }
        NUM_AVAILABLE_WORKERS = 5
    } else {
        NUM_AVAILABLE_WORKERS = 2
    }
    for (i = 1; i <= NUM_AVAILABLE_WORKERS; ++i) {
        AVAILABLE_WORKERS[i] = 1
    }
    split("", AVAILABLE_STEPS)
    for (step in ACTIVATES) if (!(step in DEPENDS_ON)) {
        AVAILABLE_STEPS[step] = 1
    }
    PROCINFO["sorted_in"] = "@ind_num_asc"
    path = ""
    TIME_LIMIT = 1000000
    split("", COMPLETES)
    for (time = 0; time < TIME_LIMIT; ++time) {
        if (time in COMPLETES) {
            for (step in COMPLETES[time]) {
                path = path step
                for (a in ACTIVATES[step]) {
                    delete DEPENDS_ON[a][step]
                    if (length(DEPENDS_ON[a]) == 0) {
                        AVAILABLE_STEPS[a] = 1
                    }
                }
                worker = WORKER_COMPLETING[step]
                AVAILABLE_WORKERS[worker] = 1
            }
        }
        while (length(AVAILABLE_STEPS) && length(AVAILABLE_WORKERS)) {
            for (step in AVAILABLE_STEPS) {
                delete AVAILABLE_STEPS[step]
                break
            }
            for (worker in AVAILABLE_WORKERS) {
                delete AVAILABLE_WORKERS[worker]
                break
            }
            WORKER_COMPLETING[step] = worker
            COMPLETES[time + COST[step]][step] = 1
        }
        if ((length(AVAILABLE_STEPS) == 0) && (length(AVAILABLE_WORKERS) == NUM_AVAILABLE_WORKERS)) {
            if (DEBUG) {
                print path > DFILE
            }
            print time
            exit
        }
    }
    aoc::compute_error("did not complete in " TIME_LIMIT " seconds")
}
