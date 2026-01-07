#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    SPARSE_SIZE = 256
    split("17 31 73 47 23", EXTRA_CODES)
    FS = ""
    for (i = 0; i <= 255; ++i) {
        ord[sprintf("%c",i)] = i
    }
}
function dump(   i) {
    for (i = 0; i < SPARSE_SIZE; ++i) {
        if (i == current_position) {
            printf(" [%d]", SPARSE[i]) > DFILE
        } else {
            printf(" %d", SPARSE[i]) > DFILE
        }
    }
    printf("\n") > DFILE
}
function reverse(start, len,   end, swaps_left, tmp) {
    end = start + len - 1
    if (end >= SPARSE_SIZE) {
        end -= SPARSE_SIZE
    }
    swaps_left = int(len/2)
    while (swaps_left--) {
        tmp = SPARSE[start]
        SPARSE[start] = SPARSE[end]
        SPARSE[end] = tmp
        if (++start == SPARSE_SIZE) {
            start = 0
        }
        if (--end == -1) {
            end = SPARSE_SIZE - 1
        }
    }
}
{
    split("", LENGTHS)
    for (i = 1; i <= NF; ++i) {
        LENGTHS[i] = ord[$i]
    }
    for (i = 1; i <= length(EXTRA_CODES); ++i) {
        LENGTHS[NF + i] = EXTRA_CODES[i]
    }
    current_position = skip_size = 0
    split("", SPARSE)
    for (i = 0; i < SPARSE_SIZE; ++i) {
        SPARSE[i] = i
    }
    if (DEBUG > 2) {
        printf("before making any moves:") > DFILE
        dump()
    }
    for (round = 1; round <= 64; ++round) {
        for (i = 1; i <= length(LENGTHS); ++i) {
            reverse(current_position, LENGTHS[i])
            current_position += LENGTHS[i] + skip_size
            current_position %= SPARSE_SIZE
            ++skip_size
            skip_size %= SPARSE_SIZE
            if (DEBUG > 3) {
                printf("after move of length %2d:", LENGTHS[i]) > DFILE
                dump()
            }
        }
        if (DEBUG > 2) {
            printf("after %d rounds:", round) > DFILE
            dump()
        }
    }
    split("", DENSE)
    for (i = 0; i < SPARSE_SIZE; ++i) {
        dest = int(i/16)
        DENSE[dest] = xor(DENSE[dest], SPARSE[i])
        if (DEBUG > 1) {
            printf("DENSE[%d] ^= SPARSE[%d](%02x) => %02x\n", dest, i, SPARSE[i], DENSE[dest]) > DFILE
        }
    }
    for (i = 0; i < (SPARSE_SIZE / 16); ++i) {
        printf("%02x", DENSE[i])
    }
    printf("\n")
}
