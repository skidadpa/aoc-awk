#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function dump(in_range,   y, x, loc) {
    for (y = 0; y < HEIGHT; ++y) {
        for (x = 0; x < WIDTH; ++x) {
            loc = y * WIDTH + x
            if (loc in UNITS) {
                ch = substr(UNITS[loc],1,1)
            } else if (loc in in_range) {
                ch = ":"
            } else {
                ch = MAP[loc]
            }
            printf "%s", ch
        }
        printf "\n"
    }
}
function coords(loc) {
    return "[" (loc % WIDTH) "," int(loc / WIDTH) "]"
}
function stats(unit) {
    return unit " (HP " HP[unit] ") at " coords(LOCATIONS[unit])
}
function enemy_army(us) {
    return (us == "G") ? "E" : "G"
}
BEGIN {
    FS = ""
    WIDTH = -1
    NUM_UNITS["E"] = NUM_UNITS["G"] = 0
    PROCINFO["sorted_in"] = "@ind_num_asc"
}
(WIDTH == -1) { WIDTH = NF }
(WIDTH != NF) { aoc::data_error("width changed from " WIDTH " to " NF) }
$0 !~ /^[#.GE]+$/ { aoc::data_error("unexpected map character") }
(NR == 1) && ($1 != "#") { aoc::data_error("top left corner is not a wall") }
{
    for (i = 1; i <= NF; ++i) {
        loc = (NR - 1) * WIDTH + (i - 1)
        switch ($i) {
        case "#":
            WALLS[loc] = 1
        case ".":
            unit = ""
            break
        case "G":
        case "E":
            ++NUM_UNITS[$i]
            unit = $i NUM_UNITS[$i]
            break
        default:
            aoc::compute_error("unexpected map character " $i)
        }
        if (unit != "") {
            LOCATIONS[unit] = loc
            UNITS[loc] = ARMIES[$i][loc] = unit
            AP[unit] = 3
            HP[unit] = 200
            MAP[loc] = "."
        } else {
            MAP[loc] = $i
        }
    }
}
END {
    HEIGHT = NR
    MOVES[-WIDTH] = MOVES[-1] = MOVES[1] = MOVES[WIDTH] = 1
    if (DEBUG) {
        print "Initial state:"
        for (army in ARMIES) {
            printf "%s:", army > DFILE
            for (loc in ARMIES[army]) {
                printf " %s", coords(loc) > DFILE
            }
            printf "\n" > DFILE
        }
        dump()
    }
    TIME_LIMIT = 999999
    done = 0
    for (t = 0; t <= TIME_LIMIT; ++t) {
        if (DEBUG > 2) {
            print "\nTURN", t >> DFILE
        }
        remaining_units = asort(UNITS, units_in_order, "@ind_num_asc")
        for (u = 1; u <= remaining_units; ++u) {
            unit = units_in_order[u]
            if (DEBUG > 5) {
                print "unit", stats(unit) > DFILE
            }
            if (!(unit in LOCATIONS)) {
                if (DEBUG > 5) {
                    print "unit", unit, "destroyed earlier in the round" > DFILE
                }
                continue
            }
            loc = LOCATIONS[unit]
            us = substr(unit,1,1)
            them = enemy_army(us)
            # try to move towards an enemy, if not already adjacent to an enemy
            split("", DISTANCES)
            move_to = 0
            distance = 1
            split("", SEEN)
            if (DEBUG > 10) {
                print "starting from", coords(loc) > DFILE
            }
            SEEN[loc] = 1
            split("", ATTACK_POINTS)
            if (length(ARMIES[them]) == 0) {
                done = 1
                break
            }
            for (m in MOVES) {
                if ((loc + m) in ARMIES[them]) {
                    if (DEBUG > 10) {
                        print "adjacent to enemy at location", coords(loc + m) > DFILE
                    }
                    distance = 0
                    break
                } else if (!((loc + m) in UNITS) && !((loc + m) in WALLS)) {
                    DISTANCES[distance][loc + m] = loc + m
                    SEEN[loc + m] = 1
                    if (DEBUG > 10) {
                        print "distance", distance, "to", coords(loc + m)
                    }
                }
            }
            if (distance) {
                for (enemy in ARMIES[them]) for (m in MOVES) {
                    if (!((enemy + m) in UNITS) && !((enemy + m) in WALLS)) {
                        ATTACK_POINTS[enemy + m] = 1
                    }
                }
                for (one_away in DISTANCES[distance]) {
                    if (one_away in ATTACK_POINTS) {
                        if (DEBUG > 10) {
                            print "in range at distance", distance, "to", coords(one_away) > DFILE
                        }
                        move_to = one_away
                        distance = 0
                        break
                    }
                }
            }
            if (DEBUG > 5) {
                print "attack points:" > DFILE
                dump(ATTACK_POINTS)
            }
            if (distance) {
                while (length(DISTANCES[distance]) > 0) {
                    if (DEBUG > 10) {
                        print "distance", distance > DFILE
                        dump(DISTANCES[distance])
                    }
                    for (start in DISTANCES[distance]) {
                        if (DEBUG > 10) {
                            print "searching from", coords(start), "at distance", distance > DFILE
                        }
                        for (m in MOVES) {
                            if (DEBUG > 10) {
                                print coords(start + m), !(((start + m) in SEEN) || ((start + m) in WALLS)) > DFILE
                            }
                            if (!((start + m) in SEEN)) {
                                if ((start + m) in ATTACK_POINTS) {
                                    move_to = DISTANCES[distance][start]
                                    break
                                } else if (!((start + m) in UNITS) && !((start + m) in WALLS)) {
                                    if (DEBUG > 10) {
                                        print "distance", distance + 1, "to", coords(start + m) > DFILE
                                    }
                                    DISTANCES[distance + 1][start + m] = DISTANCES[distance][start]
                                    SEEN[start + m] = 1
                                }
                            }
                        }
                        if (move_to) {
                            break
                        }
                    }
                    if (DEBUG > 10) {
                        print "to distance", distance + 1 > DFILE
                        dump(DISTANCES[distance + 1])
                    }
                    delete DISTANCES[distance]
                    ++distance
                    if (move_to) {
                        break
                    }
                }
            }
            if (move_to) {
                delete UNITS[loc]
                delete ARMIES[us][loc]
                loc = move_to
                LOCATIONS[unit] = loc
                UNITS[loc] = ARMIES[us][loc] = unit
                if (DEBUG > 3) {
                    print "unit", stats(unit), "moves to", coords(move_to) > DFILE
                    dump()
                }
            }
            # always attack if possible
            target_loc = 0
            for (m in MOVES) if ((loc + m) in ARMIES[them]) {
                if (!target_loc || (HP[ARMIES[them][target_loc]] > HP[ARMIES[them][loc + m]])) {
                    target_loc = loc + m
                }
            }
            if (target_loc) {
                target = ARMIES[them][target_loc]
                if (DEBUG > 2) {
                    print stats(unit), "attacks", stats(target) > DFILE
                }
                HP[target] -= AP[unit]
                if (HP[target] <= 0) {
                    if (DEBUG) {
                        print "target", target, "destroyed" > DFILE
                    }
                    delete LOCATIONS[target]
                    delete UNITS[target_loc]
                    delete ARMIES[them][target_loc]
                    delete HP[target]
                    delete AP[target]
                }
            }
        }
        if (done) {
            break
        }
    }
    sum = 0
    for (unit in LOCATIONS) {
        sum += HP[unit]
    }
    if (DEBUG) {
        print "completed after", t, "rounds with", sum, "total HP remaining" > DFILE
        dump()
    }
    print t * sum
}
