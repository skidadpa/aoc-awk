#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    DEBUG = 0
    phase = 1
    FPAT = "[a-z]+|[[:digit:]]+|[<>RA]"
    total = 0
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
    category["x"] = $2 + 0
    category["m"] = $4 + 0
    category["a"] = $6 + 0
    category["s"] = $8 + 0
    if (DEBUG > 1) {
        print "PART", $0, ":", category["x"], category["m"], category["a"], category["s"]
    }
    rule = "in"
    while (rule in rules) {
        if (DEBUG > 2) {
            print "PROCESSING RULE", rule
        }
        num_tests = rules[rule]["num_tests"]
        test_passed = 0
        for (test = 1; test <= num_tests; ++test) {
            rating = category[rules[rule][test]["category"]]
            value = rules[rule][test]["val"]
            switch (rules[rule][test]["op"]) {
                case ">":
                    test_passed = (rating > value)
                    break
                case "<":
                    test_passed = (rating < value)
                    break
                default:
                    aoc::compute_error("unrecognized op " rules[rule][test]["op"])
            }
            if (test_passed) {
                rule = rules[rule][test]["result"]
                break
            }
        }
        if (!test_passed) {
            rule = rules[rule]["default"]
        }
    }
    switch (rule) {
        case "A":
            rating = category["x"] + category["m"] + category["a"] + category["s"]
            total += rating
            if (DEBUG > 1) {
                print "ACCEPTED with rating", rating, "running total:", total
            }
            break
        case "R":
            if (DEBUG > 1) {
                print "REJECTED"
            }
            break
        default:
            aoc::compute_error("ended with rule " rule)
    }
    next
}
{
    aoc::data_error("at phase " phase)
}
END {
    print total
}
