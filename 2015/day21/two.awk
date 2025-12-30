#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[[:digit:]]+"
    WEAPON_COST[4] = 8
    WEAPON_COST[5] = 10
    WEAPON_COST[6] = 25
    WEAPON_COST[7] = 40
    WEAPON_COST[8] = 74
    ATTACK_COST[1] = 25
    ATTACK_COST[2] = 50
    ATTACK_COST[3] = 100
    ARMOR_COST[0] = 0
    ARMOR_COST[1] = 13
    ARMOR_COST[2] = 31
    ARMOR_COST[3] = 53
    ARMOR_COST[4] = 75
    ARMOR_COST[5] = 102
    DEFEND_COST[1] = 20
    DEFEND_COST[2] = 40
    DEFEND_COST[3] = 80
}
/^Hit Points: [[:digit:]]+$/ {
    boss_hp = $1
    SAMPLE_MODE = (boss_hp == 12)
    next
}
/^Damage: [[:digit:]]+$/ {
    boss_damage = $1
    next
}
/^Armor: [[:digit:]]+$/ {
    boss_armor = $1
    next
}
{
    aoc::data_error()
}
function play(boss_hp, boss_damage, boss_armor, player_damage, player_armor,   player_hp) {
    if (DEBUG > 2) {
        print "BATTLE boss with damage", player_damage, "armor", player_armor > DFILE
    }
    if (!player_hp) player_hp = 100
    while (player_hp > 0) {
        boss_hp -= boss_armor > player_damage ? 1 : (player_damage - boss_armor)
        if (DEBUG > 2) print "boss down to", boss_hp, "hp" > DFILE
        if (boss_hp <= 0) return 1
        player_hp -= player_armor > boss_damage ? 1 : (boss_damage - player_armor)
        if (DEBUG > 2) print "player down to", player_hp, "hp" > DFILE
    }
    return 0
}
function costliest_inventory(damage, armor,   w, a, R) {
    w = a = -1
    split("", R)
    if ((damage > 6) && (armor > 2)) {
        w = WEAPON_COST[damage - 3]
        a = ARMOR_COST[armor - 3]
        R[1] = ATTACK_COST[3]
        R[2] = DEFEND_COST[3]
    } else if (damage > 8) {
        w = WEAPON_COST[damage - 5]
        a = ARMOR_COST[armor]
        R[1] = ATTACK_COST[3]
        R[2] = ATTACK_COST[2]
    } else if (armor > 4) {
        w = WEAPON_COST[damage]
        a = ARMOR_COST[armor - 5]
        R[1] = DEFEND_COST[3]
        R[2] = DEFEND_COST[2]
    }
    if ((w > -1) && (a > -1) && (length(R) > 1)) {
        return w + a + R[1] + R[2]
    }
    # it is likely that the costliest inventory is in one of the above,
    # will fill in the rest only if needed...
    return 0
}
END {
    if (SAMPLE_MODE) {
        print play(boss_hp, boss_damage, boss_armor, 5, 5, 8)
        exit 0
    }
    for (damage = 4; damage <= 13; ++damage) {
        if (damage > 11) max_armor = 5
        else if (damage > 8) max_armor = 8
        else max_armor = 10
        for (armor = 0; armor <= max_armor; ++armor) {
            if (!play(boss_hp, boss_damage, boss_armor, damage, armor)) {
                LOSSES[damage,armor] = costliest_inventory(damage, armor)
                if (DEBUG > 2) print "cost", LOSSES[damage,armor] > DFILE
            }
        }
    }
    if (DEBUG) {
        print "Losing attribute combinations:" > DFILE
        for (l in LOSSES) {
            split(l, attributes, SUBSEP)
            print attributes[1], "damage", attributes[2], "armor costs", LOSSES[l] > DFILE
        }
    }
    for (l in LOSSES) {
        if (!costliest || (LOSSES[costliest] < LOSSES[l])) costliest = l
    }
    print LOSSES[costliest]
}
