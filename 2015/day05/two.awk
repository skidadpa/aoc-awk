#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) { aoc::data_error() }
{
    n = split($1, letters, "")
    for (i = 1; i < n - 1; ++i) if (letters[i] == letters[i+2]) break
    if (i >= n - 1) next
    for (i = 1; i < n - 2; ++i) for (j = i + 2; j < n; ++j)
        if (letters[i] == letters[j] && letters[i+1] == letters[j+1]) {
            ++nice
            next
        }
}
END {
    print nice
}
