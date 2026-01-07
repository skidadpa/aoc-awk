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
    split("", ONES["0"])
    split("", ONES["1"])
    ONES["1"][3] = 1
    split("", ONES["2"])
    ONES["2"][2] = 1
    split("", ONES["3"])
    ONES["3"][2] = 1
    ONES["3"][3] = 1
    split("", ONES["4"])
    ONES["4"][1] = 1
    split("", ONES["5"])
    ONES["5"][1] = 1
    ONES["5"][3] = 1
    split("", ONES["6"])
    ONES["6"][1] = 1
    ONES["6"][2] = 1
    split("", ONES["7"])
    ONES["7"][1] = 1
    ONES["7"][2] = 1
    ONES["7"][3] = 1
    split("", ONES["8"])
    ONES["8"][0] = 1
    split("", ONES["9"])
    ONES["9"][0] = 1
    ONES["9"][3] = 1
    split("", ONES["a"])
    ONES["a"][0] = 1
    ONES["a"][2] = 1
    split("", ONES["b"])
    ONES["b"][0] = 1
    ONES["b"][2] = 1
    ONES["b"][3] = 1
    split("", ONES["c"])
    ONES["c"][0] = 1
    ONES["c"][1] = 1
    split("", ONES["d"])
    ONES["d"][0] = 1
    ONES["d"][1] = 1
    ONES["d"][3] = 1
    split("", ONES["e"])
    ONES["e"][0] = 1
    ONES["e"][1] = 1
    ONES["e"][2] = 1
    split("", ONES["f"])
    ONES["f"][0] = 1
    ONES["f"][1] = 1
    ONES["f"][2] = 1
    ONES["f"][3] = 1
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
function find_all_adjacent(sector, region,   coords, x, y)
{
    if ((sector in REGIONS) || !(sector in DISK)) {
        return 0
    }
    REGIONS[sector] = region
    split(sector, coords, SUBSEP)
    x = coords[1]
    y = coords[2]
    if (DEBUG) {
        print x "," y, "region =", region > DFILE
    }
    if (x > 0) {
        find_all_adjacent((x - 1) SUBSEP y, region)
    }
    if (x < 127) {
        find_all_adjacent((x + 1) SUBSEP y, region)
    }
    if (y > 0) {
        find_all_adjacent(x SUBSEP (y - 1), region)
    }
    if (y < 127) {
        find_all_adjacent(x SUBSEP (y + 1), region)
    }
    return 1
}
{
    diskmap = ""
    split("", DISK)
    for (h = 0; h <= 127; ++h) {
        hash = knot_hash($0 "-" h)
        for (i = 1; i <= length(hash); ++i) {
            diskmap = diskmap BIN[substr(hash,i,1)]
            for (o in ONES[substr(hash,i,1)]) {
                DISK[h,(i-1)*4+o] = 1
            }
        }
        diskmap = diskmap "\n"
    }
    if (DEBUG) {
        print diskmap > DFILE
    }
    split("", REGIONS)
    region = 0
    for (sector in DISK) {
        if (find_all_adjacent(sector, region + 1)) {
            ++region
        }
    }
    print region
}
