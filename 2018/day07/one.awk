#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
$0 !~ /^Step [[:upper:]] must be finished before step [[:upper:]] can begin[.]$/ { aoc::data_error() }
{
    ACTIVATES[$2][$8] = 1
    DEPENDS_ON[$8][$2] = 1
}
END {
    split("", AVAILABLE)
    for (step in ACTIVATES) if (!(step in DEPENDS_ON)) {
        AVAILABLE[step] = 1
    }
    PROCINFO["sorted_in"] = "@ind_str_asc"
    path = ""
    while (length(AVAILABLE) != 0) {
        for (step in AVAILABLE) {
            break
        }
        path = path step
        for (a in ACTIVATES[step]) {
            delete DEPENDS_ON[a][step]
            if (length(DEPENDS_ON[a]) == 0) {
                AVAILABLE[a] = 1
            }
        }
        delete AVAILABLE[step]
    }
    print path
}
