#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function decompress(code,   len, MARKER, nxt) {
    len = 0
    while (match(code, /\(([[:digit:]]+)x([[:digit:]]+)\)/, MARKER)) {
        len += RSTART - 1
        nxt = RSTART + RLENGTH
        len += MARKER[2] * decompress(substr(code, nxt, MARKER[1]))
        code = substr(code, nxt + MARKER[1])
    }
    len += length(code)
    return len
}
{
    print decompress($0)
}
