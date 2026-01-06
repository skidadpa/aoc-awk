#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
/^forward/      { h += $2 }
/^down/         { d += $2 }
/^up/           { d -= $2 }
END             { print h * d }
