#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FS = ","
}
$0 !~ /^[[:digit:]]+(,[[:digit:]]+)*$/ {
    aoc::data_error()
}
function dump(   i) {
    for (i = 0; i < LIST_SIZE; ++i) {
        if (i == current_position) {
            printf(" [%d]", LIST[i]) > DFILE
        } else {
            printf(" %d", LIST[i]) > DFILE
        }
    }
    printf("\n") > DFILE
}
function reverse(start, len,   end, swaps_left, tmp) {
    end = start + len - 1
    if (end >= LIST_SIZE) {
        end -= LIST_SIZE
    }
    swaps_left = int(len/2)
    while (swaps_left--) {
        tmp = LIST[start]
        LIST[start] = LIST[end]
        LIST[end] = tmp
        if (++start == LIST_SIZE) {
            start = 0
        }
        if (--end == -1) {
            end = LIST_SIZE - 1
        }
    }
}
{
    LIST_SIZE = (NF == 4) ? 5 : 256
    current_position = skip_size = 0
    split("", LIST)
    for (i = 0; i < LIST_SIZE; ++i) {
        LIST[i] = i
    }
    if (DEBUG) {
        printf("before making any moves:") > DFILE
        dump()
    }
    for (i = 1; i <= NF; ++i) {
        reverse(current_position, $i)
        current_position += $i + skip_size
        if (current_position >= LIST_SIZE) {
            current_position -= LIST_SIZE
        }
        ++skip_size
        if (DEBUG) {
            printf("after move of length %2d:", $i) > DFILE
            dump()
        }
    }
    print LIST[0] * LIST[1]
}
