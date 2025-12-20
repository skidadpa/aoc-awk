#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    FS = ","
    for (c = 0; c <= 255; ++c) {
        ord[sprintf("%c",c)] = c
    }
    FOCAL_LENGTH = 0
    ORDER = 1
    HIGHEST_ORDER = 2
    for (b = 0; b <= 255; ++b) {
        split("", boxes[b, FOCAL_LENGTH])
        split("", boxes[b, ORDER])
        boxes[b, HIGHEST_ORDER] = 0
    }
}
function hash(str,   value, i) {
    value = 0
    for (i = 1; i <= length(str); ++i) {
        value += ord[substr(str,i,1)]
        value *= 17
        value %= 256
    }
    return value
}
$0 !~ /^[[:alpha:]]+-|(=[[:digit:]])(,[[:alpha:]]+-|(=[[:digit:]]))*/ {
    aoc::data_error()
}
{
    for (i = 1; i <= NF; ++i) {
        split($i, parse, /[-+=]/, ops)
        lens = parse[1]
        box = hash(lens)
        op = ops[1]
        if (DEBUG) {
            print lens, "(" box ")", op, parse[2]
        }
        switch (op) {
            case "-":
                delete boxes[box, FOCAL_LENGTH][lens]
                delete boxes[box, ORDER][lens]
                break
            case "=":
                focal_length = parse[2] + 0
                boxes[box, FOCAL_LENGTH][lens] = focal_length
                if (!(lens in boxes[box, ORDER])) {
                    boxes[box, ORDER][lens] = ++boxes[box, HIGHEST_ORDER]
                }
                break
            default:
                aoc::compute_error("unknown operation: " ops[1])
        }
    }
}
END {
    total = 0
    for (box = 0; box <= 255; ++box) {
        if (DEBUG > 2) {
            print "box", box, boxes[box, HIGHEST_ORDER], length(boxes[box, FOCAL_LENGTH]), length(boxes[box, ORDER])
        }
        asorti(boxes[box, ORDER], lens_slots, "@val_num_asc")
        for (slot in lens_slots) {
            lens = lens_slots[slot]
            power = (box + 1) * slot * boxes[box, FOCAL_LENGTH][lens]
            total += power
            if (DEBUG) {
                print "box", box, "slot", slot, "lens", lens, "focal length", boxes[box, FOCAL_LENGTH][lens], "focusing power", power, ":", total
            }
        }
    }

    print total
}
