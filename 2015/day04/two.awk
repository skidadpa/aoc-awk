#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
@load "./md5"
{
    for (i = 1; i < 999999999; ++i) if (substr(md5($0 i), 1, 6) == "000000") {
        print i
        next
    }
    print $0, "NOT FOUND"
}
