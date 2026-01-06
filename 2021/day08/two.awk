#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = "|"
    unique_lengths[2] = 1
    unique_lengths[3] = 7
    unique_lengths[4] = 4
    unique_lengths[7] = 8
}
( NF != 2 ) { aoc::data_error() }
function join(array, start, end, sep,    result, i) {
    if (sep == "") sep = " "; else if (sep == SUBSEP) sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++) result = result sep array[i]
    return result
}
function normalize(display,    a, n) {
    n = split(display, a, "")
    asort(a)
    return join(a, 1, n, SUBSEP)
}
function unmatched(x1, x2,    tmp, i, a1, a2, count) {
    split(x1, tmp, ""); for (i in tmp) a1[tmp[i]] = "*"
    split(x2, tmp, ""); for (i in tmp) a2[tmp[i]] = "*"
    count = 0
    for (i in a1) if (!(i in a2)) ++count
    return count
}
{
    n = split($1, digits, " ")
    if (n != 10) { aoc::data_error() }
    for (i in digits) digits[i] = normalize(digits[i])

    n = split($2, output, " ")
    if (n != 4) { aoc::data_error() }
    for (i in output) output[i] = normalize(output[i])

    split("", map)
    split("", remaining)
    for (i in digits) {
        len = length(digits[i])
        if (len in unique_lengths) map[digits[i]] = unique_lengths[len]
        else remaining[digits[i]] = "*"
    }

    split("", length_match)
    for (digit in map) {
        length_match[map[digit]] = digit
    }

    for (digit in remaining) {
        if (length(digit) == 5) {
            if (unmatched(digit, length_match[1]) == 3) map[digit] = 3
            else if (unmatched(length_match[4], digit) == 2) map[digit] = 2
            else if (unmatched(digit, length_match[7]) == 3) map[digit] = 5
            else { aoc::data_error() }
        } else if (length(digit) == 6) {
            if (unmatched(digit, length_match[1]) == 5) map[digit] = 6
            else if (unmatched(digit, length_match[4]) == 2) map[digit] = 9
            else if (unmatched(digit, length_match[7]) == 3) map[digit] = 0
            else { aoc::data_error() }
        } else { aoc::data_error() }
    }

    value = 0
    for (i = 1; i <= 4; ++i) value = value * 10 + map[output[i]]

    sum += value
}
END { print sum }
