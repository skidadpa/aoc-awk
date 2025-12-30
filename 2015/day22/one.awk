#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
    STOP = 999999
    DEBUG = 0
    MAX_MANA_COST = 100000
    split("Magic-missile,Drain,Shield,Poison,Recharge", SPELLS, ",")
    split("53 73 113 173 229", COST)
    split("4 2 0 0 0", DAMAGE)
    split("0 2 0 0 0", HEAL)
    split("0 0 1 0 0", SHIELD)
    split("0 0 0 1 0", POISON)
    split("0 0 0 0 1", RECHARGE)
}
/^Hit Points: [[:digit:]]+$/ {
    boss_hp = $1
    SAMPLE_MODE = (boss_hp < 50)
    next
}
/^Damage: [[:digit:]]+$/ {
    boss_damage = $1
    next
}
{
    aoc::data_error()
}
function try_next_spell(cost, spells_cast, boss, damage, hp, mana,   s, sleft, pleft, rleft) {
    split(spells_cast, S)
    if (DEBUG > 1) {
        printf("START: %d %d / %d, casting", hp, mana, boss)
        for (s in S) printf(" %s", SPELLS[S[s]])
        printf("\n")
    }
    for (s in S) {
        # PLAYER TURN
        if (DEBUG > 1) {
            printf(" PLAYER TURN: %d %d / %d, S%d P%d R%d cast %s\n", hp, mana, boss, sleft, pleft, rleft, SPELLS[S[s]])
        }
        if (pleft) {
            boss -= 3
            if (boss <= 0) {
                if (DEBUG) printf("boss died of poison before spell cast: %d %d / %d\n", hp, mana, boss)
                return cost - COST[S[s]] # won with poison, did not need spell
            }
            --pleft
        }
        if (rleft) {
            mana += 101
            --rleft
        }
        if (sleft) --sleft
        if ((mana < COST[S[s]]) || (sleft && SHIELD[S[s]]) ||
            (pleft && POISON[S[s]]) || (rleft && RECHARGE[S[s]])) {
            if (DEBUG) printf("insufficient mana to cast spell: %d %d / %d\n", hp, mana, boss)
            return 0 # cannot cast spell
        }
        mana -= COST[S[s]]
        hp += HEAL[S[s]]
        boss -= DAMAGE[S[s]]
        if (boss <= 0) {
            if (DEBUG) printf("boss died from spell: %d %d / %d\n", hp, mana, boss)
            return cost # won with spell
        }
        if (SHIELD[S[s]]) sleft = 6
        if (POISON[S[s]]) pleft = 6
        if (RECHARGE[S[s]]) rleft = 5
        # BOSS TURN
        if (DEBUG > 1) {
            printf(" BOSS TURN: %d / %d %d, S%d P%d R%d\n", boss, hp, mana, sleft, pleft, rleft)
        }
        if (pleft) {
            boss -= 3
            if (boss <= 0) {
                if (DEBUG) printf("boss died of spell plus poison: %d %d / %d\n", hp, mana, boss)
                return cost # won with spell plus poison
            }
            --pleft
        }
        if (rleft) {
            mana += 101
            --rleft
        }
        if (sleft) --sleft
        if (sleft) {
            if (damage <= 7) {
                --hp
            } else {
                hp -= damage - 7
            }
        } else {
            hp -= damage
        }
        if (hp <= 0) {
            if (DEBUG) printf("boss won: %d %d / %d\n", hp, mana, boss)
            return 0 # lost
        }
    }
    for (s in SPELLS) {
        if (DEBUG) {
            printf("At cost %d, adding", cost + COST[s])
            for (i in S) printf(" %s", SPELLS[S[i]])
            printf(" %s\n", SPELLS[s])
        }
        MANA_COST[cost + COST[s]][spells_cast " " s] = 1
    }
    if (DEBUG) printf("still trying: %d %d / %d\n", hp, mana, boss)
    return 0 # have not won nor lost yet
}
function play(boss, damage,   start_hp, start_mana, m, s, c, S, i) {
    if (!start_hp) start_hp = 50
    if (!start_mana) start_mana = 500

    for (s in SPELLS) {
        MANA_COST[COST[s]][s] = 1
        if (!m) m = COST[s]
    }

    while (m <= MAX_MANA_COST) {
        if (m in MANA_COST) {
            for (s in MANA_COST[m]) {
                if (DEBUG) {
                    split(s, S)
                    printf("At mana %d, trying spell list:", m)
                    for (i in S) {
                        printf(" %s", SPELLS[S[i]])
                    }
                    printf("\n")
                }
                c = try_next_spell(m, s, boss, damage, start_hp, start_mana)
                if (c) {
                    if (DEBUG) {
                        split(s, S)
                        printf("At mana %d (%d), won with:", m, c)
                        for (i in S) {
                            printf(" %s", SPELLS[S[i]])
                        }
                        if (c < m) printf(" (LAST NOT NEEDED)")
                        printf("\n")
                    }
                    return c
                }
            }
        }
        ++m
    }

    aoc::compute_error("no solution found")
}
END {
    if (SAMPLE_MODE) {
        print play(boss_hp, boss_damage, 10, 250)
        exit 0
    }
    print play(boss_hp, boss_damage)
}
