#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[DLRU]"
    MOVE[1]["D"] = 3
    MOVE[1]["L"] = 1
    MOVE[1]["R"] = 1
    MOVE[1]["U"] = 1
    MOVE[2]["D"] = 6
    MOVE[2]["L"] = 2
    MOVE[2]["R"] = 3
    MOVE[2]["U"] = 2
    MOVE[3]["D"] = 7
    MOVE[3]["L"] = 2
    MOVE[3]["R"] = 4
    MOVE[3]["U"] = 1
    MOVE[4]["D"] = 8
    MOVE[4]["L"] = 3
    MOVE[4]["R"] = 4
    MOVE[4]["U"] = 4
    MOVE[5]["D"] = 5
    MOVE[5]["L"] = 5
    MOVE[5]["R"] = 6
    MOVE[5]["U"] = 5
    MOVE[6]["D"] = "A"
    MOVE[6]["L"] = 5
    MOVE[6]["R"] = 7
    MOVE[6]["U"] = 2
    MOVE[7]["D"] = "B"
    MOVE[7]["L"] = 6
    MOVE[7]["R"] = 8
    MOVE[7]["U"] = 3
    MOVE[8]["D"] = "C"
    MOVE[8]["L"] = 7
    MOVE[8]["R"] = 9
    MOVE[8]["U"] = 4
    MOVE[9]["D"] = 9
    MOVE[9]["L"] = 8
    MOVE[9]["R"] = 9
    MOVE[9]["U"] = 9
    MOVE["A"]["D"] = "A"
    MOVE["A"]["L"] = "A"
    MOVE["A"]["R"] = "B"
    MOVE["A"]["U"] = 6
    MOVE["B"]["D"] = "D"
    MOVE["B"]["L"] = "A"
    MOVE["B"]["R"] = "C"
    MOVE["B"]["U"] = 7
    MOVE["C"]["D"] = "C"
    MOVE["C"]["L"] = "B"
    MOVE["C"]["R"] = "C"
    MOVE["C"]["U"] = 8
    MOVE["D"]["D"] = "D"
    MOVE["D"]["L"] = "D"
    MOVE["D"]["R"] = "D"
    MOVE["D"]["U"] = "B"
    key = 5
    CODE = ""
}
$0 !~ /^[DLRU]+$/ {
    aoc::data_error()
}
{
    for (i = 1; i <= NF; ++i) {
        key = MOVE[key][$i]
    }
    CODE = CODE key
}
END {
    print CODE
}
