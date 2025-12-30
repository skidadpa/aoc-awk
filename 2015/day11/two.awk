#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("@abcdefghijklmnopqrstuvwxyz", from, "")
    split("@bcdefghjjkmmnppqrstuvwxyza", tonext, "")
    split("@bcdefgh@@@@@@@@qrstuvwxyz@", toinc, "")
    for (i in from) {
        chnext[from[i]] = tonext[i]
        chinc[from[i]] = toinc[i]
    }
    chbad["i"] = chbad["o"] = chbad["l"] = 1
}
(NF != 1 || $1 !~ /^[a-z]{8}$/) { aoc::data_error() }
function join(array, start, end, sep,    result, i) {
    if (sep == "") sep = " "; else if (sep == SUBSEP) sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++) result = result sep array[i]
    return result
}
function invalid(p,    i, matched) {
    for (i = 1; i <= 6; ++i) if (chinc[p[i]] == p[i+1] && chinc[p[i+1]] == p[i+2]) break
    if (i > 6) return 1
    for (i = 1; i <= 8; ++i) if (p[i] in chbad) return 1
    for (i = 1; i <= 5; ++i) if (p[i] == p[i+1]) break
    if (i > 5) return 1
    matched = p[i++]
    while (++i <= 7) {
        if (p[i] == matched) continue
        if (p[i] == p[i+1]) break
    }
    if (i > 7) return 1
    return 0
}
{
    split($0, pass, "")
    for (d = 1; d <= 7; ++d) if (pass[d] in chbad) {
        pass[d] = chnext[pass[d]]
        while (++d < 8) pass[d] = "a"
        pass[8] = "@"
    }
    do {
        for (d = 8; d >= 1; --d) if ((pass[d] = chnext[pass[d]]) != "a") break
        if (pass[8] == "@") pass[8] = "a"
    } while (invalid(pass))
    do {
        for (d = 8; d >= 1; --d) if ((pass[d] = chnext[pass[d]]) != "a") break
    } while (invalid(pass))
    print join(pass, 1, 8, SUBSEP)
}
