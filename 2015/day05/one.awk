#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1) { aoc::data_error() }
/ab/ { next }
/cd/ { next }
/pq/ { next }
/xy/ { next }
/[aeiou].*[aeiou].*[aeiou]/ {
    n = split($1, letters, "")
    for (i = 1; i < n; ++i) if (letters[i] == letters[i+1]) break
    if (i < n) ++nice
}
END {
    print nice
}
