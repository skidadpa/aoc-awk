#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "([[:digit:]]+)|([|])"
    DEBUG = 0
}
/^Card +[[:digit:]]+:( +[[:digit:]]+)+ +|( +[[:digit:]]+)+$/ {
    split("", winning)
    recording_winners = 1
    next_card = $1
    ++num_cards[next_card++]
    for (i = 2; i <= NF; ++i) {
        if ($i == "|") {
            recording_winners = 0
        } else if (recording_winners) {
            winning[$i] = 1
        } else if ($i in winning) {
            num_cards[next_card++] += num_cards[$1]
        }
    }
    if (DEBUG) {
        print "Card", $1, "repeats", num_cards[$1], "times"
    }
    next
}
{
    aoc::data_error()
}
END {
    sum = 0
    for (card in num_cards) {
        sum += num_cards[card]
    }
    print sum
}
