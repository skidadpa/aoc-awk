#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS="[-,]"
    count = 0
}
{
    if (int($1) > int($2) || int($3) > int($4)) {
        aoc::data_error()
    }
    if (((int($1) <= int($3)) && (int($2) >= int($4))) ||
        ((int($1) >= int($3)) && (int($2) <= int($4)))) {
        ++count
    }
}
END {
    print count
}
