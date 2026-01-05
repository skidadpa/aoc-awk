#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    split("", INSTRUCTION)
    split("", ARGX)
    split("", ARGY)
    split("SWPP SWPL ROL ROR RBOP REV MOV", OPS)
    PROCINFO["sorted_in"] = "@ind_num_asc"
}
/^swap position [[:digit:]] with position [[:digit:]]$/ {
    INSTRUCTION[NR] = 1
    ARGX[NR] = $3 + 1
    ARGY[NR] = $6 + 1
    next
}
/^swap letter [[:lower:]] with letter [[:lower:]]$/ {
    INSTRUCTION[NR] = 2
    ARGX[NR] = $3
    ARGY[NR] = $6
    next
}
/^rotate left [[:digit:]] steps?$/ {
    INSTRUCTION[NR] = 3
    ARGX[NR] = $3
    ARGY[NR] = "NONE"
    next
}
/^rotate right [[:digit:]] steps?$/ {
    INSTRUCTION[NR] = 4
    ARGX[NR] = $3
    ARGY[NR] = "NONE"
    next
}
/^rotate based on position of letter [[:lower:]]$/ {
    INSTRUCTION[NR] = 5
    ARGX[NR] = $7
    ARGY[NR] = "NONE"
    next
}
/^reverse positions [[:digit:]] through [[:digit:]]$/ {
    INSTRUCTION[NR] = 6
    ARGX[NR] = $3 + 1
    ARGY[NR] = $5 + 1
    next
}
/^move position [[:digit:]] to position [[:digit:]]$/ {
    INSTRUCTION[NR] = 7
    ARGX[NR] = $3 + 1
    ARGY[NR] = $6 + 1
    next
}
{
    aoc::data_error("unrecognized operation")
}
END {
    if (NR < 10) {
        password = "decab"
        split("1 1 4 2", INVERSE_RBOP)
    } else {
        password = "fbgdceah"
        split("1 1 6 2 7 3 0 4", INVERSE_RBOP)
    }
    for (i = NR; i >= 1; --i) {
        if (DEBUG) {
            print "from", password, "reversing", OPS[INSTRUCTION[i]], ARGX[i], ARGY[i] > DFILE
        }
        if (ARGX[i] == ARGY[i]) {
            aoc::compute_error("duplicate arguments " ARGX[i] " and " ARGY[i] " at " i)
        }
        len = split(password, LETTERS, "")
        switch (INSTRUCTION[i]) {
        case 1: # SWPP
            tmp = LETTERS[ARGX[i]]
            LETTERS[ARGX[i]] = LETTERS[ARGY[i]]
            LETTERS[ARGY[i]] = tmp
            break
        case 2: # SWPL
            tmp = LETTERS[index(password, ARGX[i])]
            LETTERS[index(password, ARGX[i])] = LETTERS[index(password, ARGY[i])]
            LETTERS[index(password, ARGY[i])] = tmp
            break
        case 3: # ROL
            for (cnt = 0; cnt < ARGX[i]; ++cnt) {
                LETTERS[0 - cnt] = LETTERS[len - cnt]
                delete LETTERS[len - cnt]
            }
            break
        case 4: # ROR
            for (cnt = 1; cnt <= ARGX[i]; ++cnt) {
                LETTERS[len + cnt] = LETTERS[cnt]
                delete LETTERS[cnt]
            }
            break
        case 5: # RBOP
            if (!(index(password, ARGX[i]) in INVERSE_RBOP)) {
                aoc::compute_error("cannot un-RBOP " index(password, ARGX[i]))
            }
            rotations = INVERSE_RBOP[index(password, ARGX[i])]
            if (DEBUG) {
                print "rotating left by", rotations > DFILE
            }
            for (cnt = 1; cnt <= rotations; ++cnt) {
                LETTERS[len + cnt] = LETTERS[cnt]
                delete LETTERS[cnt]
            }
            break
        case 6: # REV
            low = ARGX[i] < ARGY[i] ? ARGX[i] : ARGY[i]
            high = ARGX[i] > ARGY[i] ? ARGX[i] : ARGY[i]
            while (low < high) {
                tmp = LETTERS[low]
                LETTERS[low++] = LETTERS[high]
                LETTERS[high--] = tmp
            }
            break
        case 7: # MOV
            dest = (ARGX[i] < ARGY[i]) ? ARGX[i] - 0.5 : ARGX[i] + 0.5
            LETTERS[dest] = LETTERS[ARGY[i]]
            delete LETTERS[ARGY[i]]
            break
        default:
            aoc::compute_error("unrecognized instruction " INSTRUCTION[i] " at " i)
        }
        password = ""
        for (l in LETTERS) {
            password = password LETTERS[l]
        }
    }
    print password
}
