#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "|"
    split("2|3|4|7", tmp); for (i in tmp) unique_lengths[tmp[i]] = 1
}
( NF != 2 ) { aoc::data_error() }
{
    ndigits = split($2, digits, " ")
    if (ndigits != 4) { aoc::data_error() }
    for (i in digits) if (length(digits[i]) in unique_lengths) ++easy_digit_count
}
END { print easy_digit_count }
