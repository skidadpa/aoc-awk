#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN { FPAT = "-?[0-9]+" }
function check_range() {
    if ($1 > $2 || $3 > $4 || $5 > $6) { aoc::data_error() }
    for (i = 1; i <= 5; i += 2) {
        if ($i > 50) next
        if ($i < -50) $i = -50
    }
    for (i = 2; i <= 6; i += 2) {
        if ($i < -50) next
        if ($i > 50) $i = 50
    }
}
/^off x=-?[0-9]+\.\.-?[0-9]+,y=-?[0-9]+\.\.-?[0-9]+,z=-?[0-9]+\.\.-?[0-9]+$/ {
    check_range()
    # print "turn off [" $1 "," $3 "," $5 "] => [" $2 "," $4 "," $6 "]" > DFILE
    for (x = $1; x <= $2; ++x) for (y = $3; y <= $4; ++y) for (z = $5; z <= $6; ++z) delete reactor[x,y,z]
    next
}
/^on x=-?[0-9]+\.\.-?[0-9]+,y=-?[0-9]+\.\.-?[0-9]+,z=-?[0-9]+\.\.-?[0-9]+$/ {
    check_range()
    # print "turn on [" $1 "," $3 "," $5 "] => [" $2 "," $4 "," $6 "]" > DFILE
    for (x = $1; x <= $2; ++x) for (y = $3; y <= $4; ++y) for (z = $5; z <= $6; ++z) reactor[x,y,z] = 1
    next
}
{ aoc::data_error() }
END {
    print length(reactor)
}
