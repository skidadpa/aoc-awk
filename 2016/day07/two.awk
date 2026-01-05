#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="[a-z]+"
    tls_count = 0
}
function find_abas(s, ABAS,   i) {
    for (i = 1; i <= length(s) - 2; ++i) {
        if ((substr(s, i, 1) == substr(s, i + 2, 1)) &&
            (substr(s, i, 1) != substr(s, i + 1, 1))) {
            ++ABAS[substr(s, i, 3)]
        }
    }
}
function find_babs(s,  BABS,   i) {
    for (i = 1; i <= length(s) - 2; ++i) {
        if ((substr(s, i, 1) == substr(s, i + 2, 1)) &&
            (substr(s, i, 1) != substr(s, i + 1, 1))) {
            ++BABS[substr(s, i + 1, 2) substr(s, i + 1, 1)]
        }
    }
}
$0 !~ /^[a-z]+(\[[a-z]+\][a-z]+)*$/ {
    aoc::data_error()
}
{
    split("", ABAS)
    split("", BABS)
    for (i = 1; i <= NF; i += 2) {
        find_abas($i, ABAS)
    }
    for (i = 2; i <= NF; i += 2) {
        find_babs($i, BABS)
    }
    if (DEBUG) {
        print "ABAS:" > DFILE
        for (aba in ABAS) {
            print aba, ABAS[aba] > DFILE
        }
        print "BABS:" > DFILE
        for (aba in BABS) {
            print aba, BABS[aba] > DFILE
        }
    }
    for (aba in ABAS) {
        if (aba in BABS) {
            ++tls_count
            next
        }
    }
}
END {
    print tls_count
}
