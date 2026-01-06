#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DS = "/"
    UP = ".."
}
/^\$ cd/ {
    if (NF != 3) {
        aoc::data_error()
    }
    if (substr($3,1,1) == DS) {
        pwd = substr($3,2)
    } else if ($3 == UP) {
        sub(/\/?[^\/]*$/, "", pwd)
    } else {
        pwd = pwd DS $3
    }
    if (substr(pwd,length(pwd),1) == DS) {
        aoc::data_error()
    }
    next
}
(NF != 2) {
    aoc::data_error()
}
/^\$/ {
    if ($2 != "ls") {
        aoc::data_error()
    }
    next
}
{
    DIRS[pwd][pwd DS $2] = 1
    if ($1 != "dir") {
        SIZES[pwd DS $2] = int($1)
    }
}
function compute_dir_size(top,  d, siz) {
    if (!(top in SIZES)) {
        siz = 0
        for (d in DIRS[top]) {
            if (!(d in SIZES)) {
                compute_dir_size(d)
            }
            siz += SIZES[d]
        }
        SIZES[top] = siz
    }
    DIR_SIZE[top] = SIZES[top]
}
END {
    compute_dir_size("")
    used = DIR_SIZE[""]
    available = 70000000 - used
    required = 30000000 - available
    if ((available < 0) || (required <= 0)) {
        aoc::compute_error()
    }
    smallest = used
    for (d in DIR_SIZE) {
        if (DIR_SIZE[d] >= required) {
            if (smallest > DIR_SIZE[d]) {
                smallest = DIR_SIZE[d]
            }
        }
    }
    print smallest
}
