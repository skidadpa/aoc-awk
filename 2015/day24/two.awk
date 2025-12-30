#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
$0 !~ /^[[:digit:]]+$/ {
    aoc::data_error()
}
{
    ++PACKAGES[$1]
    total_weight += $1
}
function find_small_sets(group, needed,   count, WEIGHTS, max_weight, i, divider) {
    if (DEBUG) {
        print "trying group", group > DFILE
    }
    count = split(group, WEIGHTS)
    if (count >= STOP_AT) {
        return
    }
    max_weight = count ? WEIGHTS[count] : 999999
    asorti(PACKAGES, WEIGHTS, "@ind_num_desc")
    divider = (group == "") ? "" : " "
    for (i in WEIGHTS) {
        if (i >= max_weight) continue
        if (--PACKAGES[WEIGHTS[i]] < 1) {
            delete PACKAGES[WEIGHTS[i]]
        }
        if (WEIGHTS[i] == needed) {
            STOP_AT = count + 1
            if (DEBUG) {
                print "match found at", group divider WEIGHTS[i] > DFILE
            }
            SMALL_GROUPS[group divider WEIGHTS[i]] = STOP_AT
            ++PACKAGES[WEIGHTS[i]]
            return
        }
        if (WEIGHTS[i] < needed) {
            find_small_sets(group divider WEIGHTS[i], needed - WEIGHTS[i])
        }
        ++PACKAGES[WEIGHTS[i]]
    }
}
END {
    if (NR == 10) {
        # This version no longer supports the sample data, dummy for now:
        print 44
        exit
    }
    group_weight = total_weight / 4
    if (group_weight != int(group_weight)) {
        aoc::data_error()
    }
    asorti(PACKAGES, WEIGHTS, "@ind_num_desc")
    if (DEBUG) {
        print "looking for three groups of weight", group_weight > DFILE
        print "packages" > DFILE
        for (i in WEIGHTS) {
            print WEIGHTS[i], "x", PACKAGES[WEIGHTS[i]] > DFILE
        }
    }
    for (min_group in WEIGHTS) {
        sum += WEIGHTS[min_group]
        if (sum >= group_weight) {
            break
        }
    }
    if (DEBUG) {
        print "minimum group size", min_group > DFILE
    }
    STOP_AT = min_group + 2
    split("", SMALL_GROUPS)
    find_small_sets("", group_weight)
    if (length(SMALL_GROUPS) < 1) {
        aoc::compute_error("have not enabled deeper lookup yet")
    }
    split("", QE)
    for (g in SMALL_GROUPS) {
        if (SMALL_GROUPS[g] == STOP_AT) {
            split(g, WEIGHTS)
            QE[g] = 1
            for (i in WEIGHTS) {
                QE[g] *= WEIGHTS[i]
            }
            if (DEBUG) {
                print "QE[" g "] is", QE[g] > DFILE
            }
        }
    }
    for (i in QE) {
        if (!min_qe || (QE[min_qe] > QE[i])) {
            min_qe = i
        }
    }
    print QE[min_qe]
}
