#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ""
}
{
    escaping = garbage = score = nest = 0
    for (i = 1; i <= NF; ++i) {
        if (escaping) {
            escaping = 0
            continue
        }
        switch ($i) {
        case "!":
            escaping = 1
            break
        case "{":
            if (!garbage) {
                ++nest
            }
            break
        case "}":
            if (!garbage && (nest > 0)) {
                score += nest
                --nest
            }
            break
        case "<":
            garbage = 1
            break
        case ">":
            garbage = 0
            break
        }
    }
    print score
}
