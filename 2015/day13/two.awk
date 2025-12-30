#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "[\\. ]"
}
(NF != 12 || $0 !~ /would ((gain)|(lose)) [0-9]+ happiness units by sitting next to/) {
   aoc::data_error()
}
function permute(arrangements, arrangement, items,    remaining, count) {
    if (length(items) == 1) for (item in items) {
        arrangements[arrangement item] = 0
        return 1
    }
    for (nxt in items) {
        split("", remaining)
        for (item in items) if (item != nxt) remaining[item] = 1
        count += permute(arrangements, arrangement nxt SUBSEP, remaining)
    }
    return count
}
{
    happiness[$1] = happiness[$11] = 0
    delta[$1,$11] = ($3 == "lose") ? -($4+0) : $4+0
}
END {
    if ("Santa" in happiness) { aoc::compute_error() }
    for (person in happiness) delta["Santa",person] = delta[person,"Santa"] = 0
    happiness["Santa"] = 0
    permute(seating, "", happiness)
    for (s in seating) {
        n = split(s, g, SUBSEP)
        for (i = 1; i < n; ++i) seating[s] += delta[g[i],g[i+1]] + delta[g[i+1],g[i]]
        seating[s] += delta[g[1],g[n]] + delta[g[n],g[1]]
        if (DEBUG) {
            print gensub(SUBSEP, ",", "g", s), ":", seating[s] > DFILE
        }
        if (!max || seating[s] > seating[max]) max = s
    }
    print seating[max]
}
