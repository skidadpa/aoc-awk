#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    TIE = 0
    IMMUNE_SYSTEM_HEADER = -1
    IMMUNE_SYSTEM = 1
    INFECTION_HEADER = -2
    INFECTION = 2
    FPAT = "[[:digit:]]+"
    SECTION = IMMUNE_SYSTEM_HEADER
    TEAM_NAME[TIE] = "TIE"
    TEAM_NAME[IMMUNE_SYSTEM] = "IMMUNE_SYSTEM"
    TEAM_NAME[INFECTION] = "INFECTION"
}
function set_qualifier(attacks, ary,   tmp, t) {
    split(attacks, tmp, ", ")
    for (t in tmp) {
        ary[tmp[t]] = 1
    }
}
function process_qualifier(q) {
    if (match(q, "weak to ")) {
        set_qualifier(substr(q, length("weak to ") + 1), WEAKNESSES[NR])
    } else if (match(q, "immune to ")) {
        set_qualifier(substr(q, length("immune to ") + 1), IMMUNITIES[NR])
    } else {
        aoc::data_error("improper qualifier " q)
    }
}
/^Immune System:$/ {
    if (SECTION != IMMUNE_SYSTEM_HEADER) {
        aoc::data_error("unexpected start of immune system section")
    }
    SECTION = IMMUNE_SYSTEM
    OFFSET[SECTION] = NR
    next
}
/^$/ {
    if (SECTION != IMMUNE_SYSTEM) {
        aoc::data_error("unexpected divider")
    }
    SECTION = INFECTION_HEADER
    next
}
/^Infection:$/ {
    if (SECTION != INFECTION_HEADER) {
        aoc::data_error("unexpected start of infection section")
    }
    SECTION = INFECTION
    OFFSET[SECTION] = NR
    next
}
/^[[:digit:]]+ units each with [[:digit:]]+ hit points( \(((weak)|(immune)) to [[:alpha:]]+(, [[:alpha:]]+)*(; ((weak)|(immune)) to [[:alpha:]]+(, [[:alpha:]]+)*)?\))? with an attack that does [[:digit:]]+ [[:alpha:]]+ damage at initiative [[:digit:]]+$/ {
    if (SECTION < IMMUNE_SYSTEM) {
        aoc::data_error("unexpected unit data")
    }
    GROUP[NR] = TEAM_NAME[SECTION] " group " (NR - OFFSET[SECTION])
    TEAM[NR] = SECTION
    ENEMY[NR] = (IMMUNE_SYSTEM + INFECTION) - SECTION
    STARTING_UNITS[NR] = $1
    HP[NR] = $2
    BASE_DAMAGE[NR] = $3
    start = match($0, "with an attack that does " $3 " ") + length("with an attack that does " $3 " ")
    ATTACK[NR] = substr($0, start, match($0, " damage") - start)
    ++WEAPONS[ATTACK[NR]]
    INITIATIVE[NR] = $4
    split("", WEAKNESSES[NR])
    split("", IMMUNITIES[NR])
    if (match($0, /\(((weak)|(immune)) to [[:alpha:]]+(, [[:alpha:]]+)*(; ((weak)|(immune)) to [[:alpha:]]+(, [[:alpha:]]+)*)?\)/)) {
        qualifiers = substr($0, RSTART + 1, RLENGTH - 2)
        if (match(qualifiers, "; ")) {
            semicolon = RSTART
            process_qualifier(substr(qualifiers, 1, semicolon - 1))
            process_qualifier(substr(qualifiers, semicolon + 2))
        } else {
            process_qualifier(qualifiers)
        }
    }
    if (DEBUG > 4) {
        printf "%s: %d units of %d HP,", GROUP[NR], STARTING_UNITS[NR], HP[NR] > DFILE
        printf " damage %d %s attack at initiative %d,", BASE_DAMAGE[NR], ATTACK[NR], INITIATIVE[NR] > DFILE
        printf " weaknesses:" > DFILE
        if (length(WEAKNESSES[NR])) {
            sep = " "
            for (w in WEAKNESSES[NR]) {
                printf "%s%s", sep, w > DFILE
                sep = ","
            }
        } else {
            printf " NONE" > DFILE
        }
        printf " immunities:" > DFILE
        if (length(IMMUNITIES[NR])) {
            sep = " "
            for (i in IMMUNITIES[NR]) {
                printf "%s%s", sep, i > DFILE
                sep = ","
            }
        } else {
            printf " NONE" > DFILE
        }
        printf "\n" > DFILE
    }
    next
}
{ aoc::data_error() }
function val_desc_fb_pwr_init(i1, v1, i2, v2,   ii1, ii2) {
    if (v1 == v2) {
        if (EFFECTIVE_POWERS[i2] == EFFECTIVE_POWERS[i1]) {
            return INITIATIVE[i2] - INITIATIVE[i1]
        } else {
            return EFFECTIVE_POWERS[i2] - EFFECTIVE_POWERS[i1]
        }
    }
    return v2 - v1
}
function find_effective_powers(   a, d) {
    split("", EFFECTIVE_POWERS)
    split("", DAMAGE_DONE)
    PROCINFO["sorted_in"] = "@unsorted"
    for (a in UNITS) {
        weapon = ATTACK[a]
        power = UNITS[a] * DAMAGE[a]
        EFFECTIVE_POWERS[a] = power
        for (d in TEAMS[ENEMY[a]]) {
            DAMAGE_DONE[a][d] = ATTACK_MULTIPLIER[weapon][d] * power
        }
    }
    PROCINFO["sorted_in"] = "val_desc_fb_pwr_init"
}
function complete_attack(a, d,   power, num_killed) {
    power = UNITS[a] * DAMAGE[a] * ATTACK_MULTIPLIER[ATTACK[a]][d]
    num_killed = int(power / HP[d])
    UNITS[d] -= num_killed
    if (UNITS[d] <= 0) {
        if (DEBUG > 3) {
            print "", GROUP[d], "killed at round", ROUND > DFILE
        }
        delete UNITS[d]
        delete ATTACKING[d]
        delete TEAMS[TEAM[d]][d]
        if (length(TEAMS[TEAM[d]]) == 0) {
            if (DEBUG > 3) {
                print "", TEAM_NAME[TEAM[d]], "killed at round", ROUND > DFILE
            }
            delete TEAMS[TEAM[d]]
        }
    }
    return num_killed
}
function winner(boost,   g, attacker, defender, num_killed, t, total) {
    for (g in GROUP) {
        TEAMS[TEAM[g]][g] = 1
        UNITS[g] = STARTING_UNITS[g]
        if (TEAM[g] == IMMUNE_SYSTEM) {
            DAMAGE[g] = BASE_DAMAGE[g] + boost
        } else {
            DAMAGE[g] = BASE_DAMAGE[g]
        }
    }
    if (DEBUG > 3) {
        print "AT BOOST", boost > DFILE
        ROUND = 0
    }
    while (length(TEAMS) == 2) {
        if (DEBUG > 3) {
            ++ROUND
        }
        split("", ATTACKING)
        split("", DEFENDING)
        find_effective_powers()
        for (attacker in EFFECTIVE_POWERS) {
            if (attacker in ATTACKING) {
                continue
            }
            for (defender in DAMAGE_DONE[attacker]) {
                if (defender in DEFENDING) {
                    continue
                }
                ATTACKING[attacker] = defender
                DEFENDING[defender] = attacker
                break
            }
            if (length(ATTACKING) >= length(UNITS)) {
                break
            }
        }
        num_killed = 0
        for (attacker in INITIATIVE) {
            if (!(attacker in ATTACKING)) {
                continue
            }
            num_killed += complete_attack(attacker, ATTACKING[attacker])
        }
        if (num_killed < 1) {
            if (DEBUG) {
                print "TIE at boost", boost > DFILE
            }
            if (DEBUG > 2) {
                PROCINFO["sorted_in"] = "@unsorted"
                for (t in TEAMS) {
                    total = 0
                    for (g in TEAMS[t]) {
                        total += UNITS[g]
                    }
                    print "", TEAM_NAME[t], "has", total, "units" > DFILE
                }
            }
            return TIE
        }
    }
    for (t in TEAMS) {
        if (DEBUG) {
            print TEAM_NAME[t], "wins at boost", boost > DFILE
        }
        if (DEBUG > 2) {
            total = 0
            PROCINFO["sorted_in"] = "@unsorted"
            for (g in TEAMS[t]) {
                total += UNITS[g]
            }
            total = 0
            for (g in UNITS) {
                total += UNITS[g]
            }
            print " with", total, "units" > DFILE
        }
        return t
    }
}
END {
    if (SECTION != INFECTION) {
        aoc::compute_error("did not find all expected sections")
    }
    for (g in GROUP) {
        for (w in WEAPONS) {
            ATTACK_MULTIPLIER[w][g] = (w in IMMUNITIES[g]) ? 0 : (w in WEAKNESSES[g]) ? 2 : 1
        }
    }
    boost = 0
    while (winner(boost) != IMMUNE_SYSTEM) {
        ++boost
    }
    total = 0
    for (g in UNITS) {
        total += UNITS[g]
    }
    print total
}
