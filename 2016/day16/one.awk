#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    MAP["0"] = "1"
    MAP["1"] = "0"
}
function one_step(a,   CHARS, n, b, i) {
    n = split(a, CHARS, "")
    b = MAP[CHARS[n]]
    for (i = n - 1; i >= 1; --i) {
        b = b MAP[CHARS[i]]
    }
    return a "0" b
}
function checksum(s,   c, n, i) {
    c = ""
    n = length(s)
    for (i = 1; i < n; i += 2) {
        if (substr(s, i, 1) == substr(s, i+1, 1)) {
            c = c "1"
        } else {
            c = c "0"
        }
    }
    if (length(c) % 2) {
        return c
    } else {
        return checksum(c)
    }
}
{
    if (NF == 3) {
        disk_length = $1
        a = $2
    } else if (NF == 1) {
        disk_length = 272
        a = $1
    } else {
        aoc::data_error("expecting either 1 or 3 numbers")
    }
    if (DEBUG) {
        print "starting from a =", a > DFILE
    }
    while (length(a) < disk_length) {
        a = one_step(a)
        if (DEBUG) {
            print "after a step, a =", a > DFILE
        }
    }
    if (DEBUG) {
        print "keeping", disk_length, "characters, a =", substr(a, 1, disk_length) > DFILE
    }
    print checksum(substr(a, 1, disk_length))
}
