#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
{
    text = ""
    code = $0
    while (match(code, /\(([[:digit:]]+)x([[:digit:]]+)\)/, MARKER)) {
        text = text substr(code, 1, RSTART - 1)
        for (i = 1; i <= MARKER[2]; ++i) {
            text = text substr(code, RSTART + RLENGTH, MARKER[1])
        }
        code = substr(code, RSTART + RLENGTH + MARKER[1])
    }
    text = text code
    if (DEBUG) print text > DFILE
    print length(text)
}
