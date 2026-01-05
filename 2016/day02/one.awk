#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    FPAT = "[DLRU]"
    MOVE[1]["D"] = 4
    MOVE[1]["L"] = 1
    MOVE[1]["R"] = 2
    MOVE[1]["U"] = 1
    MOVE[2]["D"] = 5
    MOVE[2]["L"] = 1
    MOVE[2]["R"] = 3
    MOVE[2]["U"] = 2
    MOVE[3]["D"] = 6
    MOVE[3]["L"] = 2
    MOVE[3]["R"] = 3
    MOVE[3]["U"] = 3
    MOVE[4]["D"] = 7
    MOVE[4]["L"] = 4
    MOVE[4]["R"] = 2
    MOVE[4]["U"] = 1
    MOVE[5]["D"] = 8
    MOVE[5]["L"] = 4
    MOVE[5]["R"] = 6
    MOVE[5]["U"] = 2
    MOVE[6]["D"] = 9
    MOVE[6]["L"] = 5
    MOVE[6]["R"] = 6
    MOVE[6]["U"] = 3
    MOVE[7]["D"] = 7
    MOVE[7]["L"] = 7
    MOVE[7]["R"] = 8
    MOVE[7]["U"] = 4
    MOVE[8]["D"] = 8
    MOVE[8]["L"] = 7
    MOVE[8]["R"] = 9
    MOVE[8]["U"] = 5
    MOVE[9]["D"] = 9
    MOVE[9]["L"] = 8
    MOVE[9]["R"] = 9
    MOVE[9]["U"] = 6
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
