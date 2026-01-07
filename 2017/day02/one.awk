#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    spreadsheet_checksum = 0
}
($0 !~ /^[[:digit:]]+([[:space:]]+[[:digit:]]+)*$/) {
    aoc::data_error()
}
{
    smallest = largest = 0
    for (i = 1; i <= NF; ++i) {
        if (!smallest || ($smallest > $i)) {
            smallest = i
        }
        if (!largest || ($largest < $i)) {
            largest = i
        }
    }
    row_checksum = $largest - $smallest
    spreadsheet_checksum += row_checksum
}
END {
    print spreadsheet_checksum
}
