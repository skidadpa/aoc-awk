#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function find_paths(path, dest,   route_len, ROUTES, r, IN_ROUTE, o) {
    if (path in PATHS) {
        return
    }
    PATHS[path] = 1
    route_len = split(path, ROUTE, ",")
    split("", IN_ROUTE)
    for (r in ROUTE) {
        IN_ROUTE[ROUTE[r]] = 1
    }
    if (ROUTE[route_len] == dest) {
        ++PATHS_TO_DEST
        return
    }
    for (o in OUTPUTS[ROUTE[route_len]]) if (!(o in IN_ROUTE)) {
        find_paths(path "," o, dest)
    }
}
BEGIN {
    FPAT = "[a-z]{3}"
}
$0 !~ /^[a-z]{3}:( [a-z]{3})+$/ {
    aoc::data_error()
}
{
    for (i = 2; i <= NF; ++i) {
        OUTPUTS[$1][$i] = 1
    }
}
END {
    split("", PATHS)
    PATHS_TO_DEST = 0
    find_paths("you", "out")
    print PATHS_TO_DEST
}
