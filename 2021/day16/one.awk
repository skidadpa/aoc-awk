#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 1 || $0 !~ /^[0-9A-F]+$/) { aoc::data_error() }
function join(array, start, end, sep,    result, i) {
    if (sep == "") sep = " "; else if (sep == SUBSEP) sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++) result = result sep array[i]
    return result
}
function field(name, size,    result, i) {
    result = bits[bitpos++]+0
    for (i = 1; i < size; ++i) result = result * 2 + bits[bitpos++]
    # print "field", name, ":", join(bits, bitpos-size, bitpos-1, SUBSEP), "=", result > DFILE
    if (bitpos > nbits + 1) { aoc::compute_error() }
    return result
}
function decode(    packet, V, T, more, I, L, i, endpos) {
    V = field("V", 3)
    packet = V
    T = field("T", 3)
    if (T == 4) {
        do {
            more = field("more", 1)
            field("data", 4)
        } while (more)
    } else {
        I = field("I", 1)
        if (I) {
            L = field("L", 11)
            for (i = 1; i <= L; ++i) packet += decode()
        } else {
            L = field("L", 15)
            endpos = bitpos + L
            while (bitpos < endpos) packet += decode()
        }
    }
    return packet
}
{
    gsub(/0/, "z")
    gsub(/1/, "0001"); gsub(/2/, "0010"); gsub(/3/, "0011")
    gsub(/4/, "0100"); gsub(/5/, "0101"); gsub(/6/, "0110")
    gsub(/7/, "0111"); gsub(/8/, "1000"); gsub(/9/, "1001")
    gsub(/A/, "1010"); gsub(/B/, "1011"); gsub(/C/, "1100")
    gsub(/D/, "1101"); gsub(/E/, "1110"); gsub(/F/, "1111")
    gsub(/z/, "0000")
    nbits = split($0, bits, "")
    bitpos = 1
    print decode()
}
