#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
function quantum_entanglement(set,   a, n, i, product) {
    n = split("" set, a)
    product = 1
    for (i = 1; i <= n; ++i) {
        product *= 0 + a[i]
    }
    return product
}
function find_groups_of_weight(grps, weight, pkgs, p, depth, all,   t, seen, sep, w, result) {
    if (depth < 1) {
        return 0
    }
    split(pkgs, t)
    split("", seen)
    for (w in t) {
        seen[t[w]] = 1
    }
    if (p) {
        seen[p] = 1
    }
    pkgs = ""
    sep = ""
    for (w in seen) {
        pkgs = pkgs sep w
        sep = " "
    }
    if ((weight " " depth ":" pkgs) in RULED_OUT) {
        return 0
    }
    if (depth == 1) {
        if ((weight in WEIGHTS) && !(weight in seen)) {
            seen[weight] = 1
            pkgs = ""
            sep = ""
            for (w in seen) {
                pkgs = pkgs sep w
                sep = " "
            }
            grps[pkgs] = quantum_entanglement(pkgs)
            return 1
        }
        if (DEBUG > 4) {
            print "RULED_OUT", weight, depth, ":", pkgs > DFILE
        }
        RULED_OUT[weight " " depth ":" pkgs] = 1
        return 0
    }
    result = 0
    for (w in WEIGHTS) if ((0 + w < weight) && !(w in seen)) {
        result += find_groups_of_weight(grps, weight - w, pkgs, w, depth - 1, all)
        if (result && !all) {
            return result
        }
    }
    if (!result) {
        if (DEBUG > 4) {
            print "RULED_OUT", weight, depth, ":", pkgs > DFILE
        }
        RULED_OUT[weight " " depth ":" pkgs] = 1
    }
    return result
}
BEGIN {
    PROCINFO["sorted_in"] = "@ind_num_desc"
    split("", RULED_OUT)
}
$0 !~ /^[[:digit:]]+$/ {
    aoc::data_error()
}
{
    if ((NR > 1) && (PACKAGES[NR - 1] >= $i)) {
        aoc::data_error("package weight out of order")
    }
    PACKAGES[NR] = 0 + $1
    WEIGHTS[$1] = NR
    TOTAL_WEIGHT += $1
}
END {
    NUM_GROUPS = 4
    group_weight = TOTAL_WEIGHT / NUM_GROUPS
    if (group_weight != int(group_weight)) {
        aoc::data_error("total weight not divisible by " NUM_GROUPS)
    }
    if (DEBUG) {
        print "total weight:", TOTAL_WEIGHT > DFILE
        print "looking for", NUM_GROUPS, "groups of weight", group_weight > DFILE
    }
    if (PACKAGES[NR] > group_weight) {
        aoc::data_error("largest package too heavy to allow " NUM_GROUPS " groups")
    }
    split("", GROUPS)
    success = 0
    for (group_size = 1; group_size < group_weight; ++group_size) {
        success = find_groups_of_weight(GROUPS, group_weight, "", "", group_size, 1)
        if (success) {
            break
        }
    }
    if (!success) {
        aoc::compute_error("could not find any groups of weight " group_weight)
    }

    if (DEBUG) {
        print "found", length(GROUPS), "groups of size", group_size > DFILE
    }
    if (DEBUG > 1) {
        for (g in GROUPS) {
            print " ", g, ":", GROUPS[g] > DFILE
        }
    }

    min_valid = 0
    for (g in GROUPS) {
        if (!min_valid || (min_valid > GROUPS[g])) {
            success = 0
            split("", _grps)
            for (next_group = 1; next_group <= (NR - group_size) / 2; ++next_group) {
                success = find_groups_of_weight(_grps, group_weight, g, "", next_group, 0)
            }
            if (!success) {
                if (DEBUG) {
                    print "Ruled out", g, ":", GROUPS[g] > DFILE
                }
                continue
            }
            # should check again on the resultant groups, although in practice this is
            # currently sufficient
        }
        if (!min_valid) {
            min_valid = GROUPS[g]
        }
        if (min_valid > GROUPS[g]) {
            min_valid = GROUPS[g]
        }
    }

    if (min_valid == 0) {
        aoc::compute_error("could not find any valid groups")
    }

    print min_valid
}
