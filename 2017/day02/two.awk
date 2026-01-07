#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    spreadsheet_checksum = 0
}
($0 !~ /^[[:digit:]]+([[:space:]]+[[:digit:]]+)*$/) {
    aoc::data_error()
}
{
    result = 0
    for (i = 1; i < NF; ++i) {
        if ($i == 0) {
            continue
        }
        for (j = i + 1; j <= NF; ++j) {
            if ($j == 0) {
                continue
            }
            quotient = ($i > $j) ? ($i / $j) : ($j / $i)
            if (quotient == int(quotient)) {
                if (result) {
                    aoc::compute_error("multiple numbers divide evenly")
                }
                result = quotient
            }
        }
    }
    row_checksum = result
    spreadsheet_checksum += row_checksum
}
END {
    print spreadsheet_checksum
}
