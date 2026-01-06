#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
{
    latest_prefix = length($0) - 3
    for (prefix = 1; prefix <= latest_prefix; ++prefix) {
        failed = 0
        for (i = prefix; (i < prefix + 3) && !failed; ++i) {
            if (index(substr($0,i+1,prefix+3-i), substr($0,i,1))) {
                failed = 1
                break
            }
        }
        if (!failed) {
            print prefix+3
            matched = 1
            break
        }
    }
    if (!matched) {
        aoc::compute_error()
    }
}
