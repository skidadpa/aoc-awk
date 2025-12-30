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
    DEBUG = 0
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
    if (!player_hp) player_hp = 100
    while (player_hp > 0) {
        boss_hp -= boss_armor > player_damage ? 1 : (player_damage - boss_armor)
        if (DEBUG > 2) print "boss down to", boss_hp, "hp"
        if (boss_hp <= 0) return 1
        player_hp -= player_armor > boss_damage ? 1 : (boss_damage - player_armor)
        if (DEBUG > 2) print "player down to", player_hp, "hp"
    }
    return 0
}
function ring_allocation_cost(damage, armor, r1, r2,   cost) {
    switch (r1) {
    case "ATTACK":
        switch (r2) {
        case "ATTACK":
            switch (damage) {
            case 8:
            case 9:
                return 999999
            case 10:
                return WEAPON_COST[7] + ATTACK_COST[2] + ATTACK_COST[1] + ARMOR_COST[armor]
            case 11:
                return WEAPON_COST[8] + ATTACK_COST[2] + ATTACK_COST[1] + ARMOR_COST[armor]
            default:
                aoc::compute_error("computing ring cost")
            }
            break
        case "DEFEND":
            break
        default:
            aoc::compute_error("computing ring cost")
        }
        break
    case "DEFEND":
        switch (r2) {
        case "DEFEND":
            switch (armor) {
            case 3:
            case 4:
                return 999999
            case 5:
                return WEAPON_COST[damage] + ARMOR_COST[2] + DEFEND_COST[2] + DEFEND_COST[1]
            case 6:
                return WEAPON_COST[damage] + ARMOR_COST[3] + DEFEND_COST[2] + DEFEND_COST[1]
            case 7:
                return WEAPON_COST[damage] + ARMOR_COST[4] + DEFEND_COST[2] + DEFEND_COST[1]
            case 8:
                return WEAPON_COST[damage] + ARMOR_COST[5] + DEFEND_COST[2] + DEFEND_COST[1]
            default:
                aoc::compute_error("computing ring cost")
            }
            break
        default:
            aoc::compute_error("computing ring cost")
        }
        break
    default:
        aoc::compute_error("computing ring cost")
    }
    # ATTACK & DEFEND
    switch (damage) {
    case 8:
        cost = WEAPON_COST[7] + ATTACK_COST[1]
        break
    case 9:
        cost = WEAPON_COST[7] + ATTACK_COST[2]
        break
    case 10:
        cost = WEAPON_COST[8] + ATTACK_COST[2]
        break
    case 11:
        cost = WEAPON_COST[8] + ATTACK_COST[3]
        break
    default:
        aoc::compute_error("computing ring cost")
    }
    switch (armor) {
    case 3:
        cost += ARMOR_COST[2] + DEFEND_COST[1]
        break
    case 4:
        cost += ARMOR_COST[2] + DEFEND_COST[2]
        break
    case 5:
        cost += ARMOR_COST[3] + DEFEND_COST[2]
        break
    case 6:
        cost += ARMOR_COST[4] + DEFEND_COST[2]
        break
    case 7:
        cost += ARMOR_COST[5] + DEFEND_COST[2]
        break
    case 8:
        cost += ARMOR_COST[5] + DEFEND_COST[3]
        break
    default:
        aoc::compute_error("computing ring cost")
    }
    return cost
}
function cheapest_ring_allocation(damage, armor,   cost, lowest) {
    lowest = ring_allocation_cost(damage, armor, "ATTACK", "ATTACK")
    cost = ring_allocation_cost(damage, armor, "ATTACK", "DEFEND")
    if (lowest < cost) lowest = cost
    cost = ring_allocation_cost(damage, armor, "DEFEND", "DEFEND")
    if (lowest < cost) lowest = cost
    return lowest
}
function cheapest_inventory(damage, armor,   w, a, R) {
    w = a = -1
    split("", R)
    if (damage < 8) {
        w = WEAPON_COST[damage]
    }
    if (armor < 3) {
        a = ARMOR_COST[armor]
    }
    if ((w > -1) && (a > -1)) {
        R[1] = R[2] = 0
    }
    if (damage > 11) {
        w = WEAPON_COST[8]
        a = ARMOR_COST[armor]
        R[1] = ATTACK_COST[3]
        R[2] = ATTACK_COST[damage - 11]
    } else if (armor > 8) {
        w = WEAPON_COST[damage]
        a = ARMOR_COST[5]
        R[1] = DEFEND_COST[3]
        R[2] = DEFEND_COST[armor - 8]
    }
    if ((w > -1) && (a < 0)) {
        switch (armor) {
        case 3:
            a = ARMOR_COST[2]
            R[1] = DEFEND_COST[1]
            R[2] = 0
            break
        case 4:
            a = ARMOR_COST[2]
            R[1] = DEFEND_COST[2]
            R[2] = 0
            break
        case 5:
            a = ARMOR_COST[2]
            R[1] = DEFEND_COST[2]
            R[2] = DEFEND_COST[1]
            break
        case 6:
            a = ARMOR_COST[3]
            R[1] = DEFEND_COST[2]
            R[2] = DEFEND_COST[1]
            break
        case 7:
            a = ARMOR_COST[4]
            R[1] = DEFEND_COST[2]
            R[2] = DEFEND_COST[1]
            break
        case 8:
            a = ARMOR_COST[5]
            R[1] = DEFEND_COST[2]
            R[2] = DEFEND_COST[1]
            break
        default:
            aoc::compute_error("armor is " armor)
        }
    }
    if ((a > -1) && (w < 0)) {
        switch (damage) {
        case 8:
            w = WEAPON_COST[7]
            R[1] = ATTACK_COST[1]
            R[2] = 0
            break
        case 9:
            w = WEAPON_COST[7]
            R[1] = ATTACK_COST[2]
            R[2] = 0
            break
        case 10:
            w = WEAPON_COST[7]
            R[1] = ATTACK_COST[2]
            R[2] = ATTACK_COST[1]
            break
        case 11:
            w = WEAPON_COST[8]
            R[1] = ATTACK_COST[2]
            R[2] = ATTACK_COST[1]
            break
        default:
            aoc::compute_error("damage is " damage)
        }
    }
    if ((w < 0) && (a < 0) && (length(R) < 1) && (damage < 10) && (armor < 5)) {
        switch (damage) {
        case 8:
            w = WEAPON_COST[7]
            R[1] = ATTACK_COST[1]
            break
        case 9:
            w = WEAPON_COST[7]
            R[1] = ATTACK_COST[2]
            break
        default:
            aoc::compute_error("single ring, damage is " damage)
        }
        switch (armor) {
        case 3:
            a = ARMOR_COST[2]
            R[2] = DEFEND_COST[1]
            break
        case 4:
            a = ARMOR_COST[2]
            R[2] = DEFEND_COST[2]
            break
        default:
            aoc::compute_error("single ring, armor is " armor)
        }
    }
    if ((w > -1) && (a > -1) && (length(R) > 1)) {
        return w + a + R[1] + R[2]
    }
    # (damage in [10..11] AND armor in [3..8]) OR (damage in [8..11] AND armor in [5..8])
    # allocate both rings to either attack or defend
    return cheapest_ring_allocation(damage, armor)
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
            if (play(boss_hp, boss_damage, boss_armor, damage, armor)) {
                WINS[damage,armor] = cheapest_inventory(damage, armor)
            }
        }
    }
    if (DEBUG) {
        print "Winning attribute combinations:"
        for (w in WINS) {
            split(w, attributes, SUBSEP)
            print attributes[1], "damage", attributes[2], "armor costs", WINS[w]
        }
    }
    for (w in WINS) {
        if (!cheapest || (WINS[cheapest] > WINS[w])) cheapest = w
    }
    print WINS[cheapest]
}
