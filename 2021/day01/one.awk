#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { prev=99999 }
{
    if ($1 > prev) ++count
    prev = $1
}
END { print count }
