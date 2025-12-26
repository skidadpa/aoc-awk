#!/usr/bin/env gawk -f
#
# Visualizer for 2023 Day 20 input data. Requires graphviz.
#
# Pipe the output to "dot", e.g.:
#
#   ./grviz.awk input.txt | dot -Tsvg > input.svg
#
BEGIN {
    FPAT="[a-z]+"
    print "digraph {"
}
/^broadcaster -> [a-z]+(, [a-z]+)*$/ {
    prefix=""
    fontcolor = "green"
}
/^%[a-z]+ -> [a-z]+(, [a-z]+)*$/ {
    prefix="%"
    fontcolor = "red"
}
/^&[a-z]+ -> [a-z]+(, [a-z]+)*$/ {
    prefix="&"
    fontcolor = "blue"
}
/^(broadcaster)|([&%][a-z]+) -> [a-z]+(, [a-z]+)*$/ {
    printf "%s [label=\"%s%s\"; fontcolor=%s]\n", $1, prefix,$1, fontcolor
    printf "%s -> {", $1
    for (i = 2; i <= NF; ++i) {
        printf " %s", $i
    }
    print " }"
}
END {
    print "}"
}
