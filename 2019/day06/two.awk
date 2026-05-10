#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ")"
}

$0 !~ /^[[:alnum:]]+[)][[:alnum:]]+$/ { aoc::data_error() }
$2 == "COM" { aoc::data_error("COM cannot orbit anything") }
$1 == "SAN" { aoc::data_error("nothing should orbit SAN") }
$1 == "YOU" { aoc::data_error("nothing should orbit YOU") }

{
    if ($2 in ORBITS) {
        aoc::data_error($2 " already orbits " ORBITS[$2])
    }
    ORBITS[$2] = $1
}

END {
    if (!("SAN" in ORBITS)) { aoc::compute_error("SAN orbit not found") }
    if (!("YOU" in ORBITS)) { aoc::compute_error("YOU orbit not found") }
    o = ORBITS["SAN"]
    d = 0
    SANTA_DISTANCE[o] = d++
    while (o in ORBITS) {
        o = ORBITS[o]
        SANTA_DISTANCE[o] = d++
    }
    if (o != "COM") {
        aoc::compute_error("central object to SAN is " o " instead of COM")
    }
    o = ORBITS["YOU"]
    d = 0
    while (!(o in SANTA_DISTANCE)) {
        ++d
        if (!(o in ORBITS)) {
            aoc::compute_error("no common orbit found")
        }
        o = ORBITS[o]
    }
    print d + SANTA_DISTANCE[o]
}
