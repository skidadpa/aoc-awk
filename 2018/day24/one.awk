#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    IMMUNE_SYSTEM_HEADER = -1
    IMMUNE_SYSTEM = 1
    INFECTION_HEADER = -2
    INFECTION = 2
    FPAT = "[[:digit:]]+"
    SECTION = IMMUNE_SYSTEM_HEADER
    TEAM_NAME[IMMUNE_SYSTEM] = "IMMUNE_SYSTEM"
    TEAM_NAME[INFECTION] = "INFECTION"
    DEBUG = 0
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
    GROUP_NAME[NR] = TEAM_NAME[SECTION] " group " (NR - OFFSET[SECTION])
    TEAMS[SECTION][NR] = 1
    TEAM[NR] = SECTION
    ENEMY[NR] = (IMMUNE_SYSTEM + INFECTION) - SECTION
    UNITS[NR] = $1
    HP[NR] = $2
    DAMAGE[NR] = $3
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
    if (DEBUG) {
        printf "%s: %d units of %d HP,", GROUP_NAME[NR], UNITS[NR], HP[NR] > DFILE
        printf " damage %d %s attack at initiative %d,", DAMAGE[NR], ATTACK[NR], INITIATIVE[NR] > DFILE
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
        EFFECTIVE_POWERS[a] = power = UNITS[a] * DAMAGE[a]
        for (d in TEAMS[ENEMY[a]]) {
            DAMAGE_DONE[a][d] = ATTACK_MULTIPLIER[weapon][d] * power
            if (DEBUG > 1) {
                print GROUP_NAME[a], "would deal", GROUP_NAME[d], DAMAGE_DONE[a][d], "damage" > DFILE
            }
        }
    }
    PROCINFO["sorted_in"] = "val_desc_fb_pwr_init"
    if (DEBUG > 3) {
        sep = ""
        printf "selection order:" > DFILE
        for (a in EFFECTIVE_POWERS) {
            printf "%s %s (%d)", sep, GROUP_NAME[a], EFFECTIVE_POWERS[a] > DFILE
            sep = ","
        }
        printf "\n" > DFILE
    }
}
function complete_attack(a, d,   power, num_killed) {
    power = UNITS[a] * DAMAGE[a] * ATTACK_MULTIPLIER[ATTACK[a]][d]
    num_killed = int(power / HP[d])
    UNITS[d] -= num_killed
    if (DEBUG) {
        printf "%s attacks %s, killing %d%s\n", GROUP_NAME[a], GROUP_NAME[d], num_killed, ((UNITS[d] <= 0) ? " (ALL)" : "") > DFILE
    }
    if (UNITS[d] <= 0) {
        delete UNITS[d]
        delete ATTACKING[d]
        delete TEAMS[TEAM[d]][d]
        if (length(TEAMS[TEAM[d]]) == 0) {
            delete TEAMS[TEAM[d]]
        }
    }
    return num_killed
}
END {
    if (SECTION != INFECTION) {
        aoc::compute_error("did not find all expected sections")
    }
    for (d in UNITS) {
        for (w in WEAPONS) {
            ATTACK_MULTIPLIER[w][d] = (w in IMMUNITIES[d]) ? 0 : (w in WEAKNESSES[d]) ? 2 : 1
        }
    }
    while (length(TEAMS) == 2) {
        if (DEBUG) {
            print "ROUND", ++ROUND > DFILE
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
                if (DEBUG > 2) {
                    print GROUP_NAME[attacker], "selects", GROUP_NAME[defender], "as a target" > DFILE
                }
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
            aoc::compute_error("stalemate: no units killed")
        }
    }
    total = 0
    if (DEBUG) {
        print "FINAL" > DFILE
    }
    PROCINFO["sorted_in"] = "@unsorted"
    for (g in UNITS) {
        if (DEBUG) {
            printf "%s has %d units\n", GROUP_NAME[g], UNITS[g] > DFILE
        }
        total += UNITS[g]
    }
    print total
}
