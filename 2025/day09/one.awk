#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function abs(x) { return x < 0 ? -x : x }
BEGIN {
    DEBUG = 0
    DFILE = "/dev/stderr"
    FS = ","
    PROCINFO["sorted_in"] = "@val_num_desc"
}
$0 !~ /^[[:digit:]]+,[[:digit:]]+$/ {
    aoc::data_error()
}
{
    X[NR] = $1
    Y[NR] = $2
    for (i = 1; i < NR; ++i) {
        AREA[i,NR] = (abs(X[NR] - X[i]) + 1) * (abs(Y[NR] - Y[i]) + 1)
    }
}
END {
    for (a in AREA) {
        print AREA[a]
        break
    }
}
