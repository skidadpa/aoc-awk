#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    phase = 1
    FPAT = "[a-z]+|[[:digit:]]+|[<>RA]"
    CATEGORIES["x"] = CATEGORIES["m"] = CATEGORIES["a"] = CATEGORIES["s"] = 1
}
(phase == 1) && /^[a-z]+{([xmas]+[<>][[:digit:]]+:([a-z]+|[AR]),)+([a-z]+|[AR])}$/ {
    rule = $1
    num_tests = (NF - 2) / 4
    rules[rule]["num_tests"] = num_tests
    if (DEBUG > 1) {
        print "RULE", rule, "has", num_tests, "test(s)"
    }
    test = 0
    for (i = 2; i < NF; i += 4) {
        ++test
        op = i + 1
        val = i + 2
        result = i + 3
        rules[rule][test]["category"] = $i
        rules[rule][test]["op"] = $op
        rules[rule][test]["val"] = $val + 0
        rules[rule][test]["result"] = $result
        if (DEBUG > 2) {
            print " ", $i, $op, $val, ":", $result
        }
    }
    def = NF
    rules[rule]["default"] = $def
    if (DEBUG > 2) {
        print " ", "default :", $def
    }
    next
}
(phase == 1) && /^$/ {
    phase = 2
    if (!("in" in rules)) {
        aoc::data_error("no input rule found")
    }
    next
}
(phase == 2) && /^{x=[[:digit:]]+,m=[[:digit:]]+,a=[[:digit:]]+,s=[[:digit:]]+}$/ {
    next
}
{
    aoc::data_error("at phase " phase)
}
function categories(path,    c, total, result) {
    result = "{"
    total = 0
    for (c in CATEGORIES) {
        result = result c ":" range_start[path][c] "-" range_end[path][c] ", "
        total += (1 + range_end[path][c] - range_start[path][c])
    }
    result = result "rating " total "}"
    return result
}
function num_combinations(rule, seen,   path, test, total, category, target, val, done_early) {
    path = seen rule
    total = 0
    if (DEBUG) {
        print "num_combinations(" path ")," categories(path)
    }

    if (rule == "A") {
        total = 1
        for (c in CATEGORIES) {
            total *= (1 + range_end[path][c] - range_start[path][c])
        }
        if (DEBUG > 4) {
            print "ACCEPTED, total =", total
        }
    } else if (rule != "R") {
        done_early = 0
        for (test = 1; test <= rules[rule]["num_tests"] && !done_early; ++test) {
            category = rules[rule][test]["category"]
            target = rules[rule][test]["result"]
            val = rules[rule][test]["val"]
            for (c in CATEGORIES) {
                range_start[path ":" target][c] = range_start[path][c]
                range_end[path ":" target][c] = range_end[path][c]
            }
            switch (rules[rule][test]["op"]) {
                case "<":
                    if (range_start[path ":" target][category] < val) {
                        if (range_end[path ":" target][category] >= val) {
                            range_end[path ":" target][category] = val - 1
                        }
                        total += num_combinations(target, path ":")
                    } else {
                        delete range_start[path ":" target]
                        delete range_end[path ":" target]
                    }
                    if (range_end[path][category] >= val) {
                        if (range_start[path][category] < val) {
                            range_start[path][category] = val
                        }
                    } else {
                        done_early = 1
                    }
                    break
                case ">":
                    if (range_end[path ":" target][category] > val) {
                        if (range_start[path ":" target][category] <= val) {
                            range_start[path ":" target][category] = val + 1
                        }
                        total += num_combinations(target, path ":")
                    } else {
                        delete range_start[path ":" target]
                        delete range_end[path ":" target]
                    }
                    if (range_start[path][category] <= val) {
                        if (range_end[path][category] > val) {
                            range_end[path][category] = val
                        }
                    } else {
                        done_early = 1
                    }
                    break
                default:
                    aoc::compute_error("unknown operation " rules[rule][test]["op"])
            }
        }
        if (!done_early) {
            target = rules[rule]["default"]
            for (c in CATEGORIES) {
                range_start[path ":" target][c] = range_start[path][c]
                range_end[path ":" target][c] = range_end[path][c]
            }
            total += num_combinations(target, path ":")
        }
    }
    delete range_start[path]
    delete range_end[path]
    if (DEBUG) {
        print "->" total
    }
    return total
}
END {
    range_start["in"]["x"] = range_start["in"]["m"] = range_start["in"]["a"] = range_start["in"]["s"] = 1
    range_end["in"]["x"] = range_end["in"]["m"] = range_end["in"]["a"] = range_end["in"]["s"] = 4000
    print num_combinations("in")
}
