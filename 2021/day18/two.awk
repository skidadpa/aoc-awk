#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1 || /[0-9][0-9]/ || $0 !~ /^\[.*\]$/) { aoc::data_error() }
function check(sn,    chars, c, depth, maxdepth) {
    split($0, chars, ""); for (c in chars) {
        switch (chars[c]) {
            case "[": if (++depth > maxdepth) maxdepth = depth; break
            case "]": if (--depth < 0) { aoc::data_error() }
        }
    }
    if (maxdepth > 4 || depth != 0) { aoc::data_error() }
    return sn
}
{ numbers[NR] = check($1) }
function reduce(snum,    n, sn, i, depth, j, left, right) {
    n = patsplit(snum, sn, "([0-9]+)|([^0-9])")

    for (i = 1; i <= n; ++i) {
        switch (sn[i]) {
        case "[":
            if (++depth > 4) {
                if (sn[i+1] !~ /[0-9]/ || sn[i+2] != "," || sn[i+3] !~ /[0-9]/ || \
                    sn[i+4] != "]") { aoc::compute_error() }
                for (j = i - 1; j > 1; --j) if (sn[j] ~ /[0-9]/) {
                    sn[j] = 0 + sn[j] + sn[i+1]
                    break
                }
                for (j = i + 5; j < n; ++j) if (sn[j] ~ /[0-9]/) {
                    sn[j] = 0 + sn[j] + sn[i+3]
                    break
                }
                sn[i] = "0"
                sn[i+1] = sn[i+2] = sn[i+3] = sn[i+4] = ""
                i = 11 * n
            }
            break
        case "]":
            --depth
            break
        case ",":
        case /[0-9]+/:
            break
        default:
            aoc::compute_error(sn[i])
        }
    }
    for (i -= n; i < n; ++i) {
        if (sn[i] ~ /[0-9]+/ && sn[i]+0 > 9) {
            left = int(sn[i] / 2)
            right = sn[i] - left
            sn[i] = "[" left "," right "]"
            i = 22 * n
        }
    }

    snum = ""; for (i in sn) snum = snum sn[i]
    return snum
}
function magnitude(    value) {
    if (currtoken > ntokens) { aoc::compute_error() }
    token = tokens[currtoken++]
    switch (token) {
    case "[":
        value = 3 * magnitude()
        if (tokens[currtoken++] != ",") { aoc::compute_error() }
        value += 2 * magnitude()
        if (tokens[currtoken++] != "]") { aoc::compute_error() }
        break
    case /[0-9]+/:
        value = token+0
        break
    default:
        aoc::compute_error()
    }
    return value
}
END {
    for (l = 1; l <= NR; ++l) for (r = 1; r <= NR; ++r) if (l != r) {
        number = "[" numbers[l] "," numbers[r] "]"
        do {
            last = number
            number = reduce(last)
        } while (last != number)
        ntokens = patsplit(number, tokens, "([0-9]+)|([^0-9])")
        currtoken = 1
        m = magnitude()
        if (m > largest) largest = m
    }
    print largest
}
