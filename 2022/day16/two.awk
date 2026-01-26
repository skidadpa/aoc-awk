#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "([A-Z][A-Z])|([[:digit:]]+)"
    split("", MEASURED)
}
(NF < 3) || ($0 !~ /^Valve [A-Z][A-Z] has flow rate=[[:digit:]]+; tunnels? leads? to valves? [A-Z][A-Z](, [A-Z][A-Z])*$/) {
    aoc::data_error()
}
{
    if (DEBUG > 2) {
        printf("%s: %d:", $1, $2) > DFILE
        for (i = 3; i <= NF; ++i) printf(" %s", $i) > DFILE
        printf("\n") > DFILE
    }
    if ($2 > 0) {
        FLOW[$1] = int($2)
    }
    for (i = 3; i <= NF; ++i) {
        TUNNELS[$1][$i] = 1
    }
}
function find_distances(start, src, dist,   dst) {
    for (dst in TUNNELS[src]) {
        if (!(dst in DISTANCE[start]) || (dist + 1 < DISTANCE[start][dst])) {
            DISTANCE[start][dst] = dist + 1
            find_distances(start, dst, dist + 1)
        }
    }
}
function find_adjacent_valves(src, dst, path,   tmp, t, p, d) {
    split(path, tmp)
    split("", p)
    for (t in tmp) {
        p[tmp[t]] = 1
    }
    if (dst in FLOW) {
        ADJACENT_VALVES[src][dst] = ADJACENT_VALVES[dst][src] = DISTANCE[src][dst]
        if (CLOSEST_VALVE > DISTANCE[src][dst]) {
            CLOSEST_VALVE = DISTANCE[src][dst]
        }
    } else {
        for (d in TUNNELS[dst]) if (!(d in p) && (d != "AA")) {
            find_adjacent_valves(src, d, (path " " d))
        }
    }
}
function find_release_permutations(path, time, released, AVAIL,   NEXT_AVAIL, src, dst, new_time, e) {
    PERMUTATIONS[path] = released
    if (time + CLOSEST_VALVE >= 26) {
        return
    }
    src = substr(path, length(path) - 1)
    split("", NEXT_AVAIL)
    for (dst in AVAIL) {
        NEXT_AVAIL[dst] = 1
    }
    for (dst in AVAIL) {
        new_time = time + COST[src][dst]
        if (new_time < 26) {
            delete NEXT_AVAIL[dst]
            if (dst in ENABLES) {
                for (e in ENABLES[dst]) {
                    NEXT_AVAIL[e] = 1
                }
            }
            find_release_permutations(path dst, new_time, released + (26 - new_time) * FLOW[dst], NEXT_AVAIL)
            NEXT_AVAIL[dst] = 1
            if (dst in ENABLES) {
                for (e in ENABLES[dst]) {
                    delete NEXT_AVAIL[e]
                }
            }
        }
    }
}
END {
    for (valve in TUNNELS) {
        find_distances(valve, valve, 0)
    }
    split("", ADJACENT_VALVES)
    CLOSEST_VALVE = 99999999
    for (src in FLOW) {
        for (dst in TUNNELS[src]) {
            find_adjacent_valves(src, dst, src)
        }
    }
    for (leaf in ADJACENT_VALVES) if (length(ADJACENT_VALVES[leaf]) == 1) {
        for (branch in ADJACENT_VALVES[leaf]) {
            break
        }
        if (FLOW[branch] * ADJACENT_VALVES[branch][leaf] > FLOW[leaf]) {
            ALWAYS_AFTER[leaf] = branch
        }
        if (!(leaf in ALWAYS_AFTER) && (length(ADJACENT_VALVES[branch]) == 2)) {
            for (trunk in ADJACENT_VALVES[branch]) if (trunk != leaf) {
                break
            }
            ALWAYS_AFTER[leaf] = trunk
        }
    }

    split("", COST)
    split("", ENABLES)
    split("", AVAILABLE)
    for (valve in FLOW) {
        COST["AA"][valve] = DISTANCE["AA"][valve] + 1
        for (dst in DISTANCE[valve]) {
            COST[valve][dst] = DISTANCE[valve][dst] + 1
        }
        if (valve in ALWAYS_AFTER) {
            ENABLES[ALWAYS_AFTER[valve]][valve] = 1
        } else {
            AVAILABLE[valve] = 1
        }
    }

    find_release_permutations("AA", 0, 0, AVAILABLE)
    if (DEBUG) {
        print length(PERMUTATIONS), "permutations"
    }
    if (DEBUG > 1) {
        PROCINFO["sorted_in"] = "@val_num_desc"
        for (valve in PERMUTATIONS) {
            print valve, "->", PERMUTATIONS[valve] > DFILE
            if (++PPRINTCOUNT > 24) {
                print "..." > DFILE
                break
            }
        }
        delete PROCINFO["sorted_in"]
    }
    bit = 1
    for (valve in FLOW) {
        MASKS[valve] = bit
        bit *= 2
    }
    split("", COMBINATIONS)
    split("", BEST)
    for (r in PERMUTATIONS) {
        mask = 0
        for (i = 3; i < length(r); i += 2) {
            mask += MASKS[substr(r,i,2)]
        }
        if (!(mask in COMBINATIONS) || (COMBINATIONS[mask] < PERMUTATIONS[r])) {
            COMBINATIONS[mask] = PERMUTATIONS[r]
            BEST[mask] = r
        }
    }
    if (DEBUG) {
        print length(COMBINATIONS), "combinations"
    }
    if (DEBUG > 1) {
        PROCINFO["sorted_in"] = "@val_num_desc"
        for (valve in COMBINATIONS) {
            printf "%04X -> %s\n", valve, COMBINATIONS[valve] > DFILE
            if (++CPRINTCOUNT > 24) {
                print "..." > DFILE
                break
            }
        }
        delete PROCINFO["sorted_in"]
    }
    max_released = 0
    s1 = s2 = 0
    for (p1 in COMBINATIONS) for (p2 in COMBINATIONS) {
        if (and(p1,p2) == 0) {
            released = COMBINATIONS[p1] + COMBINATIONS[p2]
        }
        if (max_released < released) {
            if (DEBUG) {
                s1 = p1
                s2 = p2
                m1 = COMBINATIONS[p1]
                m2 = COMBINATIONS[p2]
            }
            max_released = released
        }
    }
    if (DEBUG) {
        printf "%04X (%s, %d) + %04X (%s, %d) = %d\n", s1, BEST[s1], m1, s2, BEST[s2], m2, max_released > DFILE
    }
    print max_released
}
