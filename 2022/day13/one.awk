#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    idx = 0
    sum = 0
}
function split_list(str,   i) {
    if (str !~ /^\[.*\]$/) {
        aoc::data_error()
    }
}
function parse_item(str,   i, depth) {
    depth = 0
    for (i=1; i <= length(str); ++i) {
        ch = substr(str, i, 1)
        if (ch == "[") {
            ++depth
        } else if (ch == "]") {
            if (depth == 0) {
                return substr(str, 1, i - 1)
            }
            --depth
            if (depth == 0) {
                return substr(str, 1, i)
            }
        } else if (ch == ",") {
            if (depth == 0) {
                return substr(str, 1, i - 1)
            }
        }
    }
}
function check_pair(left, right,   left_is_number, right_is_number, left_len, il, ir, left_sublist, right_sublist, sub_result) {
    # print "checking", left, right > DFILE
    left_is_number = (left !~ /^\[/)
    right_is_number = (right !~ /^\[/)
    if (left_is_number && right_is_number) {
        # print "numeric compare" > DFILE
        return 0 + right - left
    }
    if (left_is_number) {
        left = "[" left "]"
    }
    if (right_is_number) {
        right = "[" right "]"
    }
    il = ir = 2
    while (il <= length(left)) {
        if (substr(left,il,1) == "]") {
            if (substr(right,ir,1) == "]") {
                return 0
            }
            return 1
        }
        if (substr(right,ir,1) == "]") {
            return -1
        }
        left_sublist = parse_item(substr(left, il))
        right_sublist = parse_item(substr(right, ir))
        sub_result = check_pair(left_sublist, right_sublist)
        if (sub_result != 0) {
            return sub_result
        }
        il += length(left_sublist)
        ir += length(right_sublist)
        if (substr(left,il,1) == ",") {
            ++il
        }
        if (substr(right,ir,1) == ",") {
            ++ir
        }
        # printf("{%s} {%s} left\n", substr(left,il), substr(right,ir)) > DFILE
    }
    aoc::compute_error()
}
(NF == 0) { next }
{
    packet[++npackets] = $0
    if (npackets > 1) {
        ++idx
        order = check_pair(packet[1], packet[2])
        if (order == 0) {
            aoc::data_error()
        }
        if (order > 0) {
            sum += idx
        }
        delete packet
        npackets = 0
    }
}
END {
    if (npackets) {
        aoc::data_error()
    }
    print sum
}
