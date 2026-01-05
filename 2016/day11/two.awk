#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "([1-4])|([MG][a-z][a-z])"
    PROCINFO["sorted_in"] = "@ind_str_asc"
    STEP_LIMIT = 50
    DEBUG = 0
    UP = "^"
    DOWN = "v"
    DIRECTIONS[UP] = 1
    DIRECTIONS[DOWN] = -1
    FWD = 0
    BWD = 1
    STR[FWD] = "FWD"
    STR[BWD] = "BWD"
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
        LEVELS[$1][$i] = 1
        STARTS[$i] = $1
        switch (substr($i,1,1)) {
        case "M":
            PAIR[$i] = "G" substr($i,2)
            break
        case "G":
            PAIR[$i] = "M" substr($i,2)
            break
        default:
            aoc::data_error($i)
        }
    }
}
function encode(elevator, lvls,   code, sep, lvl, type) {
    code = ""
    sep = ""
    for (lvl = 1; lvl <= 4; ++lvl) {
        code = code sep
        sep = ""
        if (elevator == lvl) {
            code = code "E"
            sep = ","
        }
        for (type in lvls[lvl]) if (lvls[lvl][type] > 0) {
            code = code sep lvls[lvl][type] type
            sep = ","
        }
        sep = ";"
    }
    return code
}
function decode(code, lvls,   elevator, floors, lvl, count, items, type) {
    elevator = -1
    split(code, floors, ";")
    for (lvl = 1; lvl <= 4; ++lvl) {
        split("", lvls[lvl])
        count = split(floors[lvl], items, ",")
        for (type = 1; type <= count; ++type) {
            if (items[type] == "E") {
                elevator = lvl
            } else {
                lvls[lvl][substr(items[type],2,2)] = substr(items[type],1,1)
            }
        }
    }
    return elevator
}
function dump(elevator, lvls,   lvl, type) {
    for (lvl in lvls) {
        printf "%d%s:", lvl, (elevator == lvl) ? "E" : " " > DFILE
        for (type in lvls[lvl]) if (lvls[lvl][type] > 0) {
            printf " %dx%s", lvls[lvl][type], type > DFILE
        }
        printf "\n" > DFILE
    }
}
END {
    sep = ""
    for (lvl = 1; lvl <= 4; ++lvl) {
        # convert from item names to type & pair location
        split("", items)
        for (item in LEVELS[lvl]) {
            ++items[substr(item,1,1) STARTS[PAIR[item]]]
        }
        split("", LEVELS[lvl])
        for (type in items) {
            LEVELS[lvl][type] = items[type]
        }
    }
    LEVELS[1]["G1"] += 2
    LEVELS[1]["M1"] += 2
    pairs = length(PAIR) / 2 + 2
    target_code = ";;;E," pairs "G4," pairs "M4"
    e = 1
    start_code = encode(e, LEVELS)
    if (DEBUG) {
        print "START:", start_code > DFILE
        print "TARGET:", target_code > DFILE
    }
    step = 0
    STEPS[step][FWD][start_code] = 1
    STEPS[step][BWD][target_code] = 1
    DISTANCE[FWD][start_code] = 0
    DISTANCE[BWD][target_code] = 0
    while ((step in STEPS) && (step <= STEP_LIMIT)) {
        for (fb = FWD; fb <= BWD; ++fb) {
            rev = !fb
            for (code in STEPS[step][fb]) {

                e = decode(code, LEVELS)
                SEEN[code] = 1
                if (code in DISTANCE[rev]) {
                    if (DEBUG) {
                        print "hit", code, STR[fb], "at", step, "and", STR[rev], "at", DISTANCE[rev][code], "steps" > DFILE
                    }
                    print DISTANCE[rev][code] + step
                    exit
                }
                DISTANCE[fb][code] = step

                # verify validity
                valid = 1
                for (level in LEVELS) if (valid) {
                    active_generator = 0
                    unprotected_chip = 0
                    for (item in LEVELS[level]) if (LEVELS[level][item] > 0) {
                        if (substr(item,1,1) == "G") {
                            active_generator = 1
                        }
                        if ((substr(item,1,1) == "M") && (substr(item,2,1) != level)) {
                            unprotected_chip = 1
                        }
                    }
                    if (active_generator && unprotected_chip) {
                        valid = 0
                    }
                }

                if (DEBUG > 3) {
                    print "STEP", step, STR[fb], "PROCESSING", code > DFILE
                }
                if (!valid) {
                    if (DEBUG > 3) {
                        print code, "INVALID" > DFILE
                    }
                    continue
                }

                if (fb == FWD) {
                    min_level = 1
                    max_level = 4
                    while ((length(LEVELS[min_level]) == 0) && (min_level < 4)) {
                        ++min_level
                    }
                } else {
                    min_level = 1
                    max_level = 4
                    while ((length(LEVELS[max_level]) == 0) && (max_level > 1)) {
                        --max_level
                    }
                }

                # add all moves that aren't in SEEN to STEPS[step + 1][fb]
                # rules for moves:
                # - always move one level up or down in range 1-4
                # - must move exactly one or two items
                # - must update matched pairs also
                split("", candidates)
                for (item in LEVELS[e]) if (LEVELS[e][item] > 0) {
                    candidates[item] = 1
                    seen_self = 0
                    for (other in LEVELS[e]) if (LEVELS[e][other] > 0) {
                        if (!seen_self) {
                            if (item == other) {
                                seen_self = 1
                                if (LEVELS[e][item] > 1) {
                                    candidates[item " " other] = 1
                                }
                            }
                            continue
                        }
                        candidates[item " " other] = 1
                    }
                }
                for (trying in candidates) {
                    n = split(trying, MOVES)
                    for (ud in DIRECTIONS) {
                        dest = e + DIRECTIONS[ud]
                        if ((dest < min_level) || (dest > max_level)) {
                            continue
                        }

                        # apply move of items/elevator:
                        # - update matching pairs
                        # - decrement count at e
                        # - increment count at destination
                        # - special handling if both parts of a pair are moving
                        if ((n > 1) && \
                            (substr(MOVES[1],1,1) != substr(MOVES[2],1,1)) && \
                            (substr(MOVES[1],2,1) == substr(MOVES[2],2,1))) {
                            for (m = 1; m <= n; ++m) {
                                mytype = substr(MOVES[m],1,1)
                                if (--LEVELS[e][MOVES[m]] < 1) delete LEVELS[e][MOVES[m]]
                                ++LEVELS[dest][mytype dest]
                            }
                        } else {
                            for (m = 1; m <= n; ++m) {
                                mytype = substr(MOVES[m],1,1)
                                ptype = (mytype == "G") ? "M" : "G"
                                ploc = substr(MOVES[m],2,1)
                                if (--LEVELS[ploc][ptype e] < 1) delete LEVELS[ploc][ptype e]
                                ++LEVELS[ploc][ptype dest]
                                if (--LEVELS[e][MOVES[m]] < 1) delete LEVELS[e][MOVES[m]]
                                ++LEVELS[dest][MOVES[m]]
                            }
                        }

                        # add new move to next step
                        new_code = encode(dest, LEVELS)
                        if (new_code in DISTANCE[rev]) {
                            if (DEBUG) {
                                print "found", new_code, "at", STR[rev], DISTANCE[rev][new_code], "while processing", code, STR[fb], "at", step > DFILE
                            }
                            print DISTANCE[rev][new_code] + step + 1
                            exit
                        }
                        if (!(new_code in SEEN)) {
                            STEPS[step + 1][fb][new_code] = 1
                        }

                        # undo move of items/elevator:
                        # - update matching pairs
                        # - decrement count at destination
                        # - increment count at e
                        # - special handling if both parts of a pair are moving
                        if ((n > 1) && \
                            (substr(MOVES[1],1,1) != substr(MOVES[2],1,1)) && \
                            (substr(MOVES[1],2,1) == substr(MOVES[2],2,1))) {
                            for (m = 1; m <= n; ++m) {
                                mytype = substr(MOVES[m],1,1)
                                if (--LEVELS[dest][mytype dest] < 1) delete LEVELS[dest][mytype dest]
                                ++LEVELS[e][MOVES[m]]
                            }
                        } else {
                            for (m = 1; m <= n; ++m) {
                                mytype = substr(MOVES[m],1,1)
                                ptype = (mytype == "G") ? "M" : "G"
                                ploc = substr(MOVES[m],2,1)
                                if (--LEVELS[ploc][ptype dest] < 1) delete LEVELS[ploc][ptype dest]
                                ++LEVELS[ploc][ptype e]
                                if (--LEVELS[dest][MOVES[m]] < 1) delete LEVELS[dest][MOVES[m]]
                                ++LEVELS[e][MOVES[m]]
                            }
                        }
                    }
                }
            }
        }
        delete STEPS[step]
        ++step
    }
    if (step > STEP_LIMIT) {
        aoc::compute_error("No solution found in " STEP_LIMIT " steps")
    }
    aoc::compute_error("Ran out of steps to try after " step " steps")
}
