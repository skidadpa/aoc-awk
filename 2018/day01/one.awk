#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
{ FREQUENCY += $1 }
END {
    print FREQUENCY
}
