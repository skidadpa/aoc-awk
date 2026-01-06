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
    if ((int($1) <= int($4)) && (int($2) >= int($3))) {
        ++count
    }
}
END {
    print count
}
