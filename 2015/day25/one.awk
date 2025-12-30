#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
}
function code(n,   i, c) {
    c = 20151125
    for (i = 1; i < n; ++i) {
        c = (c * 252533) % 33554393
    }
    return c
}
function code_index(row, col,   n, i) {
    n = 0
    for (i = 1; i <= col; ++i) { n += i }
    for (i = 0; i < row - 1; ++i) { n += col + i }
    if (DEBUG) { print "code is at index", n > DFILE }
    return n
}
$0 !~ /^To continue, please consult the code grid in the manual\.  Enter the code at row [[:digit:]]+, column [[:digit:]]+\.$/ {
    aoc::data_error()
}
{
    if (DEBUG) { print "code is at row", $1, "col", $2 > DFILE }
    print code(code_index($1, $2))
}
