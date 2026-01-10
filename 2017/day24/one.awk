#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function build(connect, strength, bridge,   components, p, used) {
    if (bridge in BRIDGES) {
        return
    }
    split(bridge, components, ",")
    split("", used)
    if (DEBUG) {
        printf "building from %u, strength %u, using:", connect, strength > DFILE
    }
    for (p in components) {
        if (DEBUG) {
            printf " %s", components[p] > DFILE
        }
        used[components[p]] = 1
    }
    if (DEBUG) {
        printf "\n" > DFILE
    }
    if (DEBUG > 10) {
        for (p in used) {
            print "used[" p "] =", used[p] > DFILE
        }
    }
    BRIDGES[bridge] = strength
    if (MAX_STRENGTH < strength) {
        MAX_STRENGTH = strength
    }
    for (p in PARTS[connect]) {
        if (DEBUG > 5) {
            print connect "/" p, ":", (PARTS[connect][p] in used) ? "used" : "OK" > DFILE
        }
        if (!(PARTS[connect][p] in used)) {
            build(p, strength + connect + p, bridge "," PARTS[connect][p])
        }
    }
}
BEGIN {
    MAX_STRENGTH = 0
    DEBUG = 0
    FS = "/"
}
$0 !~ /^[[:digit:]]+[/][[:digit:]]+$/ { aoc::data_error() }
{
    if ($2 in PARTS[$1]) {
        aoc::data_error("duplicate bridge types not currently supported")
    }
    PARTS[$1][$2] = NR
    if (DEBUG) {
        print "PARTS[" $1 "][" $2 "] =", NR > DFILE
    }
    if ($1 != $2) {
        if ($1 in PARTS[$2]) {
            aoc::data_error("duplicate bridge types not currently supported")
        }
        if (DEBUG) {
            print "PARTS[" $2 "][" $1 "] =", NR > DFILE
        }
        PARTS[$2][$1] = NR
    }
}
END {
    build(0, 0, 0)
    print MAX_STRENGTH
}
