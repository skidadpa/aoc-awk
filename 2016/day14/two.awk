#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
@load "./md5"
BEGIN {
    THREE = "000|111|222|333|444|555|666|777|888|999"
    THREE = THREE "|aaa|bbb|ccc|ddd|eee|fff"
    FIVE = "00000|11111|22222|33333|44444|55555|66666|77777|88888|99999"
    FIVE = FIVE "|aaaaa|bbbbb|ccccc|ddddd|eeeee|fffff"
    LIMIT = 100000
}
{
    for (idx = 0; idx < LIMIT; ++idx) {
        if (DEBUG && (idx % 1000 == 0)) { print idx > DFILE }
        hash = md5($0 idx)
        for (i = 1; i <= 2016; ++i) {
            hash = md5(hash)
        }
        found = match(hash, THREE)
        if (found) {
            MATCH3[idx] = substr(hash, found, 3)
            while (found = match(hash, FIVE)) {
                MATCH5[substr(hash, found, 3)][idx] = hash
                hash = substr(hash, found + 5)
            }
        }
        i = idx - 1000
        if ((i >= 0) && (i in MATCH3) && (MATCH3[i] in MATCH5)) {
            for (m in MATCH5[MATCH3[i]]) {
                if (0 + m > 0 + i) {
                    if (DEBUG) {
                        print "index", i, "triple", MATCH3[i], "matches index", m, "five in", MATCH5[MATCH3[i]][m] > DFILE
                    }
                    KEY[i] = 1
                    if (length(KEY) >= 64) {
                        print i
                        next
                    }
                }
            }
        }
    }
    aoc::compute_error("no match found after " LIMIT " hashes tried")
}
