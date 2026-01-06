#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT="([a-z][a-z][a-z][a-z])|([[:digit:]]+)|([-+*/])"
}
(NF == 2) && /^[a-z][a-z][a-z][a-z]: [[:digit:]]+$/ {
    VALUE[$1] = int($2)
    next
}
(NF != 4) {
    aoc::data_error()
}
/^[a-z][a-z][a-z][a-z]: [a-z][a-z][a-z][a-z] [-+*/] [a-z][a-z][a-z][a-z]$/ {
    COMPUTE[$1]["left"] = $2
    COMPUTE[$1]["op"] = $3
    COMPUTE[$1]["right"] = $4
    next
}
{
    aoc::data_error()
}
function contains_human(monkey) {
    if (monkey in VALUE) {
        return monkey == "humn"
    } else {
        return contains_human(COMPUTE[monkey]["left"]) || contains_human(COMPUTE[monkey]["right"])
    }
}
function find_human_value(monkey, want_value) {
    if (DEBUG) {
        print "trying to set value of", monkey, "to", want_value > DFILE
    }
    if (monkey in VALUE) {
        if (monkey == "humn") {
            if (DEBUG) {
                print "set value of", monkey, "to", want_value > DFILE
            }
            VALUE[monkey] = want_value
        }
    } else {
        if (DEBUG) {
            print "finding value where", monkey, "=", COMPUTE[monkey]["left"], COMPUTE[monkey]["op"], COMPUTE[monkey]["right"], "=", want_value > DFILE
        }
        switch (COMPUTE[monkey]["op"]) {
        case "+":
            if (contains_human(COMPUTE[monkey]["left"])) {
                if (DEBUG) {
                    print "left operand", COMPUTE[monkey]["left"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["left"], want_value - find_value(COMPUTE[monkey]["right"]))
            }
            if (contains_human(COMPUTE[monkey]["right"])) {
                if (DEBUG) {
                    print "right operand", COMPUTE[monkey]["right"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["right"], want_value - find_value(COMPUTE[monkey]["left"]))
            }
            break
        case "-":
            if (contains_human(COMPUTE[monkey]["left"])) {
                if (DEBUG) {
                    print "left operand", COMPUTE[monkey]["left"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["left"], find_value(COMPUTE[monkey]["right"]) + want_value)
            }
            if (contains_human(COMPUTE[monkey]["right"])) {
                if (DEBUG) {
                    print "right operand", COMPUTE[monkey]["right"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["right"], find_value(COMPUTE[monkey]["left"]) - want_value)
            }
            break
        case "*":
            if (contains_human(COMPUTE[monkey]["left"])) {
                if (DEBUG) {
                    print "left operand", COMPUTE[monkey]["left"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["left"], want_value / find_value(COMPUTE[monkey]["right"]))
            }
            if (contains_human(COMPUTE[monkey]["right"])) {
                if (DEBUG) {
                    print "right operand", COMPUTE[monkey]["right"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["right"], want_value / find_value(COMPUTE[monkey]["left"]))
            }
            break
        case "/":
            if (contains_human(COMPUTE[monkey]["left"])) {
                if (DEBUG) {
                    print "left operand", COMPUTE[monkey]["left"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["left"], find_value(COMPUTE[monkey]["right"]) * want_value)
            }
            if (contains_human(COMPUTE[monkey]["right"])) {
                if (DEBUG) {
                    print "right operand", COMPUTE[monkey]["right"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["right"], find_value(COMPUTE[monkey]["left"]) / want_value)
            }
            break
        case "=":
        default:
            aoc::compute_error("computing " monkey)
        }
    }
}
function find_value(monkey) {
    if (!(monkey in VALUE)) {
        if (DEBUG) {
            print "computing", monkey, "=", COMPUTE[monkey]["left"], COMPUTE[monkey]["op"], COMPUTE[monkey]["right"] > DFILE
        }
        switch (COMPUTE[monkey]["op"]) {
        case "+":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) + find_value(COMPUTE[monkey]["right"])
            break
        case "-":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) - find_value(COMPUTE[monkey]["right"])
            break
        case "*":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) * find_value(COMPUTE[monkey]["right"])
            break
        case "/":
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) / find_value(COMPUTE[monkey]["right"])
            break
        case "=":
            if (contains_human(COMPUTE[monkey]["left"])) {
                if (DEBUG) {
                    print "left operand", COMPUTE[monkey]["left"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["left"], find_value(COMPUTE[monkey]["right"]))
            }
            if (contains_human(COMPUTE[monkey]["right"])) {
                if (DEBUG) {
                    print "right operand", COMPUTE[monkey]["right"], "contains human" > DFILE
                }
                find_human_value(COMPUTE[monkey]["right"], find_value(COMPUTE[monkey]["right"]))
            }
            VALUE[monkey] = find_value(COMPUTE[monkey]["left"]) == find_value(COMPUTE[monkey]["right"])
            break
        default:
            aoc::compute_error("computing " monkey)
        }
        if (DEBUG) {
            print "computed value of", monkey, "as", COMPUTE[monkey]["left"], COMPUTE[monkey]["op"], COMPUTE[monkey]["right"], "=", VALUE[monkey] > DFILE
        }
    }
    if (DEBUG) {
        print "value of", monkey, "is", VALUE[monkey] > DFILE
    }
    return VALUE[monkey]
}
END {
    COMPUTE["root"]["op"] = "="
    root_value = find_value("root")
    if (DEBUG) {
        print "root is", root_value > DFILE
    }
    print VALUE["humn"]
}
