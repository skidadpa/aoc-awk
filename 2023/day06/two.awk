#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    phase = 1
}
($0 ~ /^Time:( +[[:digit:]]+)+$/) && (phase == 1) {
    ++phase
    time = ""
    for (i = 2; i <= NF; ++i) {
        time = time $i
    }
    time = time + 0
    next
}
($0 ~ /^Distance:( +[[:digit:]]+)+$/) && (phase == 2) {
    ++phase
    distance = ""
    for (i = 2; i <= NF; ++i) {
        distance = distance $i
    }
    distance = distance + 0
    next
}
{
    aoc::data_error()
}
END {
    wins = 0
    for (i = 1; i < time; ++i) {
        if ((time - i) * i > distance) {
            ++wins
        }
    }
    print wins
}
