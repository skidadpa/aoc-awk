#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
/^forward/      { h += $2; d += aim * $2 }
/^down/         { aim += $2 }
/^up/           { aim -= $2 }
END             { print h * d }
