#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    SPARSE_SIZE = 256
    split("17 31 73 47 23", EXTRA_CODES)
    for (i = 0; i <= 255; ++i) {
        ORD[sprintf("%c",i)] = i
    }
    BIN["0"] = "...."
    BIN["1"] = "...#"
    BIN["2"] = "..#."
    BIN["3"] = "..##"
    BIN["4"] = ".#.."
    BIN["5"] = ".#.#"
    BIN["6"] = ".##."
    BIN["7"] = ".###"
    BIN["8"] = "#..."
    BIN["9"] = "#..#"
    BIN["a"] = "#.#."
    BIN["b"] = "#.##"
    BIN["c"] = "##.."
    BIN["d"] = "##.#"
    BIN["e"] = "###."
    BIN["f"] = "####"
    ONES["0"] = 0
    ONES["1"] = 1
    ONES["2"] = 1
    ONES["3"] = 2
    ONES["4"] = 1
    ONES["5"] = 2
    ONES["6"] = 2
    ONES["7"] = 3
    ONES["8"] = 1
    ONES["9"] = 2
    ONES["a"] = 2
    ONES["b"] = 3
    ONES["c"] = 2
    ONES["d"] = 3
    ONES["e"] = 3
    ONES["f"] = 4
}
function dump(sparse,   i) {
    for (i = 0; i < SPARSE_SIZE; ++i) {
        if (i == current_position) {
            printf(" [%d]", sparse[i]) > DFILE
        } else {
            printf(" %d", sparse[i]) > DFILE
        }
    }
    printf("\n") > DFILE
}
function reverse(sparse, start, len,   end, swaps_left, tmp) {
    end = start + len - 1
    if (end >= SPARSE_SIZE) {
        end -= SPARSE_SIZE
    }
    swaps_left = int(len/2)
    while (swaps_left--) {
        tmp = sparse[start]
        sparse[start] = sparse[end]
        sparse[end] = tmp
        if (++start == SPARSE_SIZE) {
            start = 0
        }
        if (--end == -1) {
            end = SPARSE_SIZE - 1
        }
    }
}
function knot_hash(key,   lengths, i, current_position, skip_size, round, dense, out) {
    split("", lengths)
    for (i = 1; i <= length(key); ++i) {
        lengths[i] = ORD[substr(key,i,1)]
    }
    for (i = 1; i <= length(EXTRA_CODES); ++i) {
        lengths[length(key) + i] = EXTRA_CODES[i]
    }
    current_position = skip_size = 0
    split("", sparse)
    for (i = 0; i < SPARSE_SIZE; ++i) {
        sparse[i] = i
    }
    if (DEBUG > 2) {
        printf("before making any moves:") > DFILE
        dump(sparse)
    }
    for (round = 1; round <= 64; ++round) {
        for (i = 1; i <= length(lengths); ++i) {
            reverse(sparse, current_position, lengths[i])
            current_position += lengths[i] + skip_size
            current_position %= SPARSE_SIZE
            ++skip_size
            skip_size %= SPARSE_SIZE
            if (DEBUG > 3) {
                printf("after move of length %2d:", lengths[i]) > DFILE
                dump(sparse)
            }
        }
        if (DEBUG > 2) {
            printf("after %d rounds:", round) > DFILE
            dump(sparse)
        }
    }
    split("", dense)
    for (i = 0; i < SPARSE_SIZE; ++i) {
        out = int(i/16)
        dense[out] = xor(dense[out], sparse[i])
        if (DEBUG > 1) {
            printf("dense[%d] ^= sparse[%d](%02x) => %02x\n", out, i, sparse[i], dense[out]) > DFILE
        }
    }
    out = ""
    for (i = 0; i < (SPARSE_SIZE / 16); ++i) {
        out = out sprintf("%02x", dense[i])
    }
    return out
}
{
    disk = ""
    used = 0
    for (h = 0; h <= 127; ++h) {
        hash = knot_hash($0 "-" h)
        for (i = 1; i <= length(hash); ++i) {
            disk = disk BIN[substr(hash,i,1)]
            used += ONES[substr(hash,i,1)]
        }
        disk = disk "\n"
    }
    if (DEBUG) {
        print disk > DFILE
    }
    print used
}
