#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
{
    o2[NR] = co2[NR] = $1
    if (length($1) > maxlen) maxlen = length($1)
}
function filter(data, idx, co2mode,    elem, count, keep)
{
    for (elem in data) ++count[substr(data[elem], idx, 1)]
    if (co2mode) keep = (count[0] > count[1]) ? "1" : "0"
    else keep = (count[0] > count[1]) ? "0" : "1"
    for (elem in data) if (substr(data[elem], idx, 1) != keep) delete data[elem]
    if (length(data) > 1 && idx < maxlen) filter(data, idx + 1, co2mode)
}
END {
    filter(o2, 1, 0)
    filter(co2, 1, 1)
    if (length(o2) != 1 || length(co2) != 1) { aoc::compute_error("illegal result") }
    for (elem in o2) for (i = 1; i <= maxlen; ++i) o = o*2 + substr(o2[elem], i, 1)
    for (elem in co2) for (i = 1; i <= maxlen; ++i) c = c*2 + substr(co2[elem], i, 1)
    print o * c
}
