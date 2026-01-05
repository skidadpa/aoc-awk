#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "([1-4])|([MG][a-z][a-z])"
    ELEVATOR = 1
    ITEM_STARTS["EEE"] = "1"
    BACKWARD_LIMIT = 25
    FORWARD_LIMIT = 50
}
$0 ~! /^The ((first)|(second)|(third)|(fourth)) floor contains [-a-z]+\.$/ {
    aoc::data_error()
}
{
    sub(/The first floor/, "1")
    sub(/The second floor/, "2")
    sub(/The third floor/, "3")
    sub(/The fourth floor/, "4")
    $0 = gensub(/an? ([a-z][a-z])[a-z]*-compatible microchip/, "M\\1", "g")
    $0 = gensub(/an? ([a-z][a-z])[a-z]* generator/, "G\\1", "g")
}
{
    for (i = 2; i <= NF; ++i) {
        ITEM_STARTS[$i] = $1
        switch (substr($i,1,1)) {
        case "M":
            CHIP_NAMES[$i] = "G" substr($i,2)
            break
        case "G":
            ISOTOPE_NAMES[$i] = "M" substr($i,2)
            break
        default:
            aoc::data_error($i)
        }
    }
}
function reverse(path,   PATH, n, i) {
    n = split(path, PATH)
    path = PATH[n]
    for (i = n - 1; i >= 1; --i) {
        path = path " " PATH[i]
    }
    return path
}
function dump(code,   LEVELS, l, i) {
    for (l = 4; l >= 1; --l) {
        printf("%d", l) > DFILE
        for (i in ITEMS) {
            if (level(code, i) == l) {
                printf(" %s", ITEMS[i]) > DFILE
            } else {
                printf(" ...") > DFILE
            }
        }
        printf("\n") > DFILE
    }
}
function legal(code,   g, c, l, m) {
    for (g in ISOTOPES) {
        c = ISOTOPES[g]
        l = level(code, g)
        for (m in CHIPS) {
            if ((m != c) && (l == level(code, m)) && (l != level(code, CHIPS[m]))) {
                return 0
            }
        }
    }
    return 1
}
function apply_moves(s, to, i1, i2,   e, i) {
    e = to
    for (i = 2; i <= length(s); ++i) {
        if ((i == i1) || (i == i2)) {
            e = e to
        } else {
            e = e substr(s,i,1)
        }
    }
    if (DEBUG > 3) {
        print "from", s, "evaluating move to", to, "of", i1, i2, "yielding", e > DFILE
    }
    return e
}
function level(code, i) {
    return int(substr(code, i, 1))
}
function find_next_steps(LAST_STEPS, NEXT_STEPS, PATHS, TARGETS,
                         s, nxt, lvl, dst, i1, i2, i3, i4, TO_TRY, ok, move) {
    if (DEBUG > 2) {
        print "calling find_next_steps with length(LAST_STEPS) =", length(LAST_STEPS) > DFILE
    }
    split("", NEXT_STEPS)
    split("", TO_TRY)
    for (s in LAST_STEPS) {
        if (DEBUG > 2) {
            print "searching from:", s > DFILE
            dump(s)
        }
        nxt = LAST_STEPS[s] " "
        lvl = level(s, ELEVATOR)
        if (DEBUG > 3) {
            print "elevator is at level", lvl > DFILE
        }
        for (dst = lvl + 1; dst >= lvl - 1; dst -= 2) if ((dst >= 1) && (dst <= 4)) {
            if (DEBUG > 3) {
                print "evaluating moves from level", lvl, "to level", dst > DFILE
            }
            for (i1 in CHIPS) if (level(s, i1) == lvl) {
                for (i2 in CHIPS) if (level(s, i2) == lvl) {
                    move = apply_moves(s, dst, i1, i2)
                    TO_TRY[move] = nxt move
                }
                if (level(s, CHIPS[i1]) == lvl) {
                    move = apply_moves(s, dst, i1, CHIPS[i1])
                    TO_TRY[move] = nxt move
                }
            }
            for (i1 in ISOTOPES) if (level(s,i1) == lvl) {
                for (i2 in ISOTOPES) if (level(s,i2) == lvl) {
                    move = apply_moves(s, dst, i1, i2)
                    TO_TRY[move] = nxt move
                }
            }
        }
    }
    for (move in TO_TRY) {
        if (DEBUG > 2) {
            print "evaluating", move, "at", TO_TRY[move] > DFILE
            dump(move)
        }
        if (move in TARGETS) {
            return nxt reverse(TARGETS[move])
        }
        if (!(move in PATHS)) {
            if (legal(move)) {
                PATHS[move] = TO_TRY[move]
                NEXT_STEPS[move] = PATHS[move]
                if (DEBUG > 1) {
                    print "adding", move, "at", PATHS[move] > DFILE
                    if (DEBUG > 2) {
                        dump(move)
                    }
                }
            }
        }
    }
    if (DEBUG > 2) {
        print "find_next_steps returns", length(NEXT_STEPS), "next steps" > DFILE
    }
    return ""
}
END {
    asorti(ITEM_STARTS, ITEMS, "@ind_str_asc")
    start = ""
    for (i in ITEMS) {
        start = start ITEM_STARTS[ITEMS[i]]
        ITEM_NUMBERS[ITEMS[i]] = i
    }
    for (i in CHIP_NAMES) {
        CHIPS[ITEM_NUMBERS[i]] = ITEM_NUMBERS[CHIP_NAMES[i]]
    }
    for (i in ISOTOPE_NAMES) {
        ISOTOPES[ITEM_NUMBERS[i]] = ITEM_NUMBERS[ISOTOPE_NAMES[i]]
    }
    start = start "1111"
    next_item = length(ITEMS)
    ITEMS[++next_item] = "Gdi"
    ITEM_NUMBER["Gdi"] = next_item
    ISOTOPES[next_item] = next_item + 2
    ITEMS[++next_item] = "Gel"
    ITEM_NUMBER["Gel"] = next_item
    ISOTOPES[next_item] = next_item + 2
    ITEMS[++next_item] = "Mdi"
    ITEM_NUMBER["Mdi"] = next_item
    CHIPS[next_item] = next_item - 2
    ITEMS[++next_item] = "Mel"
    ITEM_NUMBER["Mel"] = next_item
    CHIPS[next_item] = next_item - 2
    for (i in CHIPS) {
        if (ISOTOPES[CHIPS[i]] != i) {
            aoc::compute_error("computing CHIP/ISOTOPE matches")
        }
    }
    for (i in ISOTOPES) {
        if (CHIPS[ISOTOPES[i]] != i) {
            aoc::compute_error("computing CHIP/ISOTOPE matches")
        }
    }
    if (!legal(start)) {
        dump(start)
        aoc::compute_error("initial configuration illegal")
    }
    end = gensub(/./, "4", "g", start)
    FORWARD_PATHS[start] = start
    BACKWARD_PATHS[end] = end
    if (DEBUG) {
        print "searching backward from goal:", end > DFILE
        dump(end)
    }
    NXT[0][end] = end
    for (i = 0; i < BACKWARD_LIMIT; ++i) {
        found_match = find_next_steps(NXT[i], NXT[i + 1], BACKWARD_PATHS, FORWARD_PATHS)
        if (found_match) {
            if (DEBUG) { print found_match > DFILE }
            print split(found_match, FOUND_MATCH) - 1
            exit 0
        }
        delete NXT[i]
    }
    if (DEBUG) {
        print "searching forward from start:", start > DFILE
        dump(start)
    }
    delete NXT
    NXT[0][start] = start
    for (i = 0; i < FORWARD_LIMIT; ++i) {
        found_match = find_next_steps(NXT[i], NXT[i + 1], FORWARD_PATHS, BACKWARD_PATHS)
        if (found_match) {
            if (DEBUG) { print found_match > DFILE }
            print split(found_match, FOUND_MATCH) - 1
            exit 0
        }
    }
    aoc::compute_error("no solution after " BACKWARD_LIMIT " backward and " FORWARD_LIMIT " forward steps")
}
