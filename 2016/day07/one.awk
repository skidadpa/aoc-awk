#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="[a-z]+"
    tls_count = 0
}
function is_abba(s,   i) {
    for (i = 1; i <= length(s) - 3; ++i) {
        if ((substr(s, i, 1) == substr(s, i + 3, 1)) &&
            (substr(s, i + 1, 1) == substr(s, i + 2, 1)) &&
            (substr(s, i, 1) != substr(s, i + 1, 1))) {
            return 1
        }
    }
    return 0
}
$0 !~ /^[a-z]+(\[[a-z]+\][a-z]+)*$/ {
    aoc::data_error()
}
{
    for (i = 2; i <= NF; i += 2) {
        if (is_abba($i)) {
            next
        }
    }
    for (i = 1; i <= NF; i += 2) {
        if (is_abba($i)) {
            ++tls_count
            next
        }
    }
}
END {
    print tls_count
}
