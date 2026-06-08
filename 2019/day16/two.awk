#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"

$0 !~ /^[[:digit:]]+$/ { aoc::data_error() }

{
    signal = $0
    offset = 0 + substr(signal,1,7)
    if (DEBUG) {
        print "Input signal:", signal > DFILE
        print "Message offset:", offset > DFILE
    }
    output_len = length(signal) * 10000
    if (offset > output_len) {
        aoc::data_error("offset " offset " beyond end of output")
    }
    if (offset < output_len / 2) {
        aoc::data_error("offset " offset " not in second half of output")
    }
    back_len = output_len - offset
    back_copies = aoc::ceil(output_len / back_len)
    back_data = signal
    while (length(back_data) < back_len) {
        back_data = signal back_data
    }
    if (DEBUG) {
        print "Data length:", back_len > DFILE
    }
    back_data = substr(back_data, length(back_data) - back_len + 1)
    split(back_data, data, "")
    if (DEBUG > 2) {
        printf "WORKING: " > DFILE
    }
    for (phase = 1; phase <= 100; ++phase) {
        sum = 0
        back_next = ""
        for (i = back_len; i > 0; --i) {
            sum += data[i]
            data[i] = sum % 10
        }
        if (DEBUG > 2) {
            printf "." > DFILE
            fflush(DFILE)
        }
    }
    if (DEBUG > 2) {
        printf "\n" > DFILE
    }
    out = data[1]
    for (i = 2; i <= 8; ++i) {
        out = out * 10 + data[i]
    }
    print out
}
