#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
@load "./md5"
$0 !~ /^[a-z]+$/ {
    aoc::data_error()
}
{
    count = 0
    code = ""
    for (i = 0; i < 9999999999; ++i) if (substr(md5($0 i), 1, 5) == "00000") {
        code = code substr(md5($0 i), 6, 1)
        if (DEBUG) {
            print i, code > DFILE
        }
        if (++count >= 8) {
            print code
            next
        }
    }
    print $0, "CODE NOT FOUND"
}
