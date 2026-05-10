#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ")"
}

$0 !~ /^[[:alnum:]]+[)][[:alnum:]]+$/ { aoc::data_error() }
$2 == "COM" { aoc::data_error("COM cannot orbit anything") }

{
    if ($2 in ORBITS) {
        aoc::data_error($2 " already orbits " ORBITS[$2])
    }
    ORBITS[$2] = $1
}

END {
    total = 0
    for (obj in ORBITS) {
        o = obj
        while (o in ORBITS) {
            ++total
            o = ORBITS[o]
        }
        if (o != "COM") {
            aoc::compute_error("central object to " obj " is " o " instead of COM")
        }
    }
    print total
}
