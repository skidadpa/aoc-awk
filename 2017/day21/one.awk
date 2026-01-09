#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function apply_map(str, map,   rslt, m, s, row, col) {
    rslt = ""
    for (m = 1; m <= length(map); ++m) {
        s = 0 + substr(map,m,1)
        rslt = rslt substr(str,s,1)
    }
    return rslt
}
function square_root(n) {
    while (n > MAX_SQUARE) {
        ++MAX_ROOT
        MAX_SQUARE = MAX_ROOT * MAX_ROOT
        ROOTS[MAX_SQUARE] = MAX_ROOT
    }
    if (n in ROOTS) {
        return ROOTS[n]
    } else {
        aoc::compute_error(n " is not a square")
        return sqrt(n)
    }
}
function subdivide(str,   size, n, rslt, sep, row, col, y, x) {
    size = square_root(length(str))
    if (size % 2 == 0) {
        # break into 2x2 pieces
        n = 2
    } else if (size % 3 == 0) {
        # break into 3x3 pieces
        n = 3
    } else {
        aoc::compute_error(str "of size " size " is not divisible by 2 or 3")
    }
    rslt = ""
    sep = ""
    for (row = 0; row < size / n; ++row) {
        for (col = 0; col < size / n; ++col) {
            rslt = rslt sep
            sep = " "
            for (y = 0; y < n; ++y) {
                for (x = 0; x < n; ++x) {
                    rslt = rslt substr(str, (row * n + y) * size + col * n + x + 1, 1)
                }
            }
        }
    }
    if (DEBUG > 7) {
        print str, "size", size, "n", n, "divides into", rslt > DFILE
    }
    return rslt
}
function combine(str,   blocks, n, blocksize, rslt, row, y, col) {
    n = square_root(split(str, blocks))
    blocksize = square_root(length(blocks[1]))
    rslt = ""
    for (row = 0; row < n; ++row) {
        for (y = 0; y < blocksize; ++y) {
            for (col = 0; col < n; ++col) {
                rslt = rslt substr(blocks[row * n + col + 1], y * blocksize + 1, blocksize)
            }
        }
    }
    return rslt
}
function dump(str,   size, y) {
    size = square_root(length(str))
    for (y = 0; y < size; ++y) {
        print substr(str, y * size + 1, size) > DFILE
    }
}
function dumpify(str,   n, blocksize, blocks, line, sep, row, y, col, x) {
    n = square_root(split(str, blocks))
    blocksize = square_root(length(blocks[1]))
    for (row = 0; row < n; ++row) {
        if (row) {
            line = ""
            sep = ""
            for (col = 0; col < n; ++col) {
                line = line sep
                sep = "+"
                for (x = 0; x < blocksize; ++x) {
                    line = line "-"
                }
            }
            print line > DFILE
        }
        for (y = 0; y < blocksize; ++y) {
            line = ""
            sep = ""
            for (col = 0; col < n; ++col) {
                line = line sep substr(blocks[row * n + col + 1], y * blocksize + 1, blocksize)
                sep = "|"
            }
            print line > DFILE
        }
    }
}
function slashify(str,   size, rslt, sep, y) {
    size = square_root(length(str))
    rslt = ""
    sep = ""
    for (y = 0; y < size; ++y) {
        rslt = rslt sep substr(str, y * size + 1, size)
        sep = "/"
    }
    return rslt
}
function annotate(str) {
    return slashify(BLOCKS[b]) " (" slashify(BASE_RULES[BLOCKS[b]]) ")"
}
function on_pixels(str,   i, count) {
    count = 0
    for (i = 1; i <= length(str); ++i) {
        if (substr(str, i, 1) == "#") {
            ++count
        }
    }
    return count
}
function add_rule(size, src, dst,   m, mapped_src) {
    if (src in RULES) {
        # rule seen twice, convert existing mapped rule to a singleton
        aoc::data_error("duplicate rule maps to " RULES[src])
    }
    for (m in MAPPINGS[size]) {
        mapped_src = apply_map(src, m)
        RULES[mapped_src] = dst
        BASE_RULES[mapped_src] = src
    }
}
BEGIN {
    # Base  Rotations     Flips
    # ====  =========     =====
    # 12    31  43  24    21  13  34  42
    # 34    42  21  13    43  24  12  31
    # 123   741 987 369   321 147 789 963
    # 456   852 654 258   654 258 456 852
    # 789   963 321 147   987 369 123 741
    curr = "1234"
    rot = "3142"
    flip = "2143"
    for (i = 1; i <= 4; ++i) {
        MAPPINGS[2][curr] = 1
        MAPPINGS[2][apply_map(curr,flip)] = 1
        curr = apply_map(curr, rot)
    }
    curr = "123456789"
    rot = "741852963"
    flip = "321654987"
    for (i = 1; i <= 4; ++i) {
        MAPPINGS[3][curr] = 1
        MAPPINGS[3][apply_map(curr,flip)] = 1
        curr = apply_map(curr, rot)
    }
    FPAT = "[.#]+"
    MAX_ROOT = 0
    MAX_SQUARE = MAX_ROOT * MAX_ROOT
    ROOTS[MAX_SQUARE] = MAX_ROOT
    split("", RULES)
}
/^[.#]{2}[/][.#]{2} => [.#]{3}[/][.#]{3}[/][.#]{3}$/ {
    add_rule(2, $1 $2, $3 $4 $5)
    next
}
/^[.#]{3}[/][.#]{3}[/][.#]{3} => [.#]{4}[/][.#]{4}[/][.#]{4}[/][.#]{4}$/ {
    add_rule(3, $1 $2 $3, $4 $5 $6 $7)
    next
}
{ aoc::data_error() }
END {
    NUM_ITERATIONS = (NR < 3) ? 2 : 5
    image = ".#...####"
    if (DEBUG) {
        print "At start,", on_pixels(image), "pixels are on:" > DFILE
        dumpify(subdivide(image))
    }
    for (iteration = 1; iteration <= NUM_ITERATIONS; ++iteration) {
        split(subdivide(image), BLOCKS)
        subblocks = ""
        sep = ""
        for (b in BLOCKS) {
            subblocks = subblocks sep
            sep = " "
            if (!(BLOCKS[b] in RULES)) {
                aoc::compute_error(BLOCKS[b] " not in ENHANCEMENT RULES")
            }
            if (DEBUG > 2) {
                print "replacing", annotate(BLOCKS[b]), "with", slashify(RULES[BLOCKS[b]]) > DFILE
                if (DEBUG > 4) {
                    dump(BLOCKS[b])
                    print "becomes" > DFILE
                    dump(RULES[BLOCKS[b]])
                }
            }
            subblocks = subblocks RULES[BLOCKS[b]]
        }
        image = combine(subblocks)
        if (DEBUG) {
            print "After iteration", iteration ",", on_pixels(image), "pixels are on:" > DFILE
            dumpify(subdivide(image))
            # dump(image)
        }
    }
    print on_pixels(image)
}
