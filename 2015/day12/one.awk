#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
{
    sum = 0
    n = split($0, numbers, /[^-0-9]+/)
    for (i in numbers) sum += numbers[i]
    print sum
}
