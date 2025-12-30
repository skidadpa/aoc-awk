#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function replace_join(array, replacing, with,    i, val, result) {
    for (i in array) {
        val = (i == replacing) ? with : array[i]
        if (result) result = result SUBSEP val; else result = val
    }
    return result
}
BEGIN {
    FPAT = "[A-Z][a-z]?"
}
/^[A-Z][a-z]? => [A-Z]/ {
    r = $2
    for (i = 3; i <= NF; ++i) r = r SUBSEP $i
    ++nreplacements[$1]
    replacements[$1,nreplacements[$1]] = r
    next
}
/e => [A-Z]/ {
    r = $1
    for (i = 2; i <= NF; ++i) r = r SUBSEP $i
    ++nreplacements["e"]
    replacements["e",nreplacements[$1]] = r
    next
}
/=>/ { aoc::data_error() }
(NF > 0) {
    delete element
    for (i = 1; i <= NF; ++i) element[i] = $i
    delete elements
    for (i = 1; i <= NF; ++i) if (element[i] in nreplacements)
        for (j = 1; j <= nreplacements[element[i]]; ++j)
            elements[replace_join(element, i, replacements[element[i],j])] = 1
    print length(elements)
}
