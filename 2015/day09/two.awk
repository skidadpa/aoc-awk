#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = " = "
}
(NF != 2) { aoc::data_error() }
{
    if (split($1, route, " to ") != 2) { aoc::data_error() }
    towns[route[1]] = towns[route[2]] = 1
    distance[route[1],route[2]] = distance[route[2],route[1]] = $2
}
function permute(path, visiting,    remaining) {
    if (length(visiting) == 1) for (town in visiting) {
        paths[path town] = 0
        return
    }
    for (town in visiting) {
        split("", remaining)
        for (visit in visiting) if (visit != town) remaining[visit] = 1
        permute(path town SUBSEP, remaining)
    }
}
END {
    npaths = length(towns) * (length(towns) - 1)
    if (length(distance) != npaths) { aoc::data_error() }
    permute("", towns)
    for (path in paths) {
        n = split(path, route, SUBSEP)
        for (i = 1; i < n; ++i) paths[path] += distance[route[i],route[i+1]]
        if (!longest || paths[longest] < paths[path]) longest = path
        if (DEBUG) {
            print gensub(SUBSEP, " -> ", "g", path), ":", paths[path] > DFILE
        }
    }
    print paths[longest]
}
