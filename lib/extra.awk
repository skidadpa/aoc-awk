#
# Extra functions for AWK library for Advent of Code challenges
#
# These could be generalized and/or implemented differently. The
# intent is to pull them into aoc.awk once the implementation is
# settled. Until then the implementation may change.
#

@namespace "aoc"

##
# @brief Join a set of contiguous numbered array elements into a string
#
# @param array A numerically-indexed array
# @param start First element to combine
# @param end Last element to combine
# @param sep Separator, defaults to " "
#
# @return String containing the elements separated by sep
#
function join_range(array, start, end, sep,    result, i) {
    if ((sep == "") && (sep == 0)) {
        sep = " "
    }
    result = array[start]
    for (i = start + 1; i <= end; i++) {
        result = result sep array[i]
    }
    return result
}

function join_values(array, sep,    result, s, i) {
    if ((sep == "") && (sep == 0)) {
        sep = " "
    }
    s = ""
    for (i in array) {
        result = result s array[i]
        s = sep
    }
    return result
}

function join_indices(array, sep,    result, s, e) {
    if ((sep == "") && (sep == 0)) {
        sep = " "
    }
    s = ""
    for (e in array) {
        result = result s e
        s = sep
    }
    return result
}

#
# Operations in coordinate space
#
# Many of the challenges operate on matrices and generally
# assume that the X axis is left/right and the Y access is
# up/down, with lower numbers being up/left, consistent
# with the normal parsing order when input
#

function left(coord,    c) {
    split(coord, c, SUBSEP)
    return (c[1] - 1) SUBSEP c[2]
}

function right(coord,    c) {
    split(coord, c, SUBSEP)
    return (c[1] + 1) SUBSEP c[2]
}

function up(coord,    c) {
    split(coord, c, SUBSEP)
    return c[1] SUBSEP (c[2] - 1)
}

function down(coord,    c) {
    split(coord, c, SUBSEP)
    return c[1] SUBSEP (c[2] + 1)
}

function addcoords(a, b,    ca, cb) {
    split(a, ca, SUBSEP)
    split(b, cb, SUBSEP)
    return (ca[1]+cb[1]) SUBSEP (ca[2]+cb[2]) SUBSEP (ca[3]+cb[3])
}
function negcoords(a,    cab) {
    split(a, ca, SUBSEP)
    return (0-ca[1]) SUBSEP (0-ca[2]) SUBSEP (0-ca[3])
}
function set_offset(s, p) {
    offset[s] = negcoords(p)
    return s
}

# TODO: this can be generalized for any number of dimensions
function manhattan(a, b,    ca, cb, x, y) {
    split(a, ca, SUBSEP)
    split(b, cb, SUBSEP)
    x = (ca[1] - cb[1]); if (x < 0) x = -x
    y = (ca[2] - cb[2]); if (y < 0) y = -y
    return x + y
}

function manhattan3(a, b,    ca, cb, x, y, z) {
    split(a, ca, SUBSEP)
    split(b, cb, SUBSEP)
    x = (ca[1] - cb[1]); if (x < 0) x = -x
    y = (ca[2] - cb[2]); if (y < 0) y = -y
    z = (ca[3] - cb[3]); if (z < 0) z = -z
    return x + y + z
}

function move(from, dir,    coords) {
    split(from, coords, SUBSEP)
    switch (dir) {
        case ">":
            return ((coords[1] + 1) SUBSEP coords[2])
        case "v":
            return (coords[1] SUBSEP (coords[2] + 1))
        case "<":
            return ((coords[1] - 1) SUBSEP coords[2])
        case "^":
            return (coords[1] SUBSEP (coords[2] - 1))
        default:
            error("PROCESSING ERROR: unrecognized direction " dir)
    }
}
function return_path(dir) {
    split(from, coords, SUBSEP)
    switch (dir) {
        case ">":
            return "<"
        case "v":
            return "^"
        case "<":
            return ">"
        case "^":
            return "v"
        default:
            error("PROCESSING ERROR: unrecognized direction " dir)
    }
}

function move(loc, direction,   coords) {
    split(loc, coords, SUBSEP)
    switch (direction) {
        case "0": # RIGHT
            ++coords[1]
            break
        case "1": # DOWN
            ++coords[2]
            break
        case "2": # LEFT
            --coords[1]
            break
        case "3": # UP
            --coords[2]
            break
        default:
            error("PROCESSING ERROR: bad direction " direction)
    }
    return coords[1] SUBSEP coords[2]
}
function coordinates(loc,   coords) {
    split(loc, coords, SUBSEP)
    return "(" coords[1] "," coords[2] ")"
}
function facing(direction) {
    switch (direction) {
        case "0": # RIGHT
            return "RIGHT"
        case "1": # DOWN
            return "DOWN"
        case "2": # LEFT
            return "LEFT"
        case "3": # UP
            return "UP"
    }
    error("PROCESSING ERROR: bad direction " direction)
}

function move(from, dir,   coords) {
    split(from, coords, SUBSEP)
    switch (dir) {
        case "E":
            return ((coords[1] + 1) SUBSEP coords[2])
        case "S":
            return (coords[1] SUBSEP (coords[2] + 1))
        case "W":
            return ((coords[1] - 1) SUBSEP coords[2])
        case "N":
            return (coords[1] SUBSEP (coords[2] - 1))
        default:
            error("PROCESSING ERROR: unknown direction " dir)
    }
}

