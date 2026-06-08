#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

BEGIN {
    PAT[0] = 0
    PAT[1] = 1
    PAT[2] = 0
    PAT[3] = -1
}

function ones_digit(n) {
    return "" aoc::abs(n % 10)
}

function fft_phase(inp,   len, out, o, sum, i) {
    len = length(inp)
    out = ""
    for (o = 1; o <= len; ++o) {
        sum = 0
        for (i = 1; i <= len; ++i) {
            sum += (0 + substr(inp, i, 1)) * PAT[int((i % (4 * o)) / o)]
        }
        out = out ones_digit(sum)
    }
    return out
}

$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }

{
    signal = $0
    if (DEBUG) {
        print "Input signal:", signal > DFILE
    }
    for (phase = 1; phase <= 100; ++phase) {
        signal = fft_phase(signal)
        if (DEBUG > 1) {
            if ((DEBUG > 3) || (phase < 5)) {
                print "After", phase, "phases:", signal > DFILE
            }
        }
    }
    print substr(signal, 1, 8)
}
