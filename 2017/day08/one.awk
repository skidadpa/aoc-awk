#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ < -?[[:digit:]]+$/ {
    if (REGISTER[$5] < int($7)) {
        REGISTER[$1] += int(($2 == "inc") ? $3 : -$3)
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ <= -?[[:digit:]]+$/ {
    if (REGISTER[$5] <= int($7)) {
        REGISTER[$1] += int(($2 == "inc") ? $3 : -$3)
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ == -?[[:digit:]]+$/ {
    if (REGISTER[$5] == int($7)) {
        REGISTER[$1] += int(($2 == "inc") ? $3 : -$3)
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ != -?[[:digit:]]+$/ {
    if (REGISTER[$5] != int($7)) {
        REGISTER[$1] += int(($2 == "inc") ? $3 : -$3)
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ >= -?[[:digit:]]+$/ {
    if (REGISTER[$5] >= int($7)) {
        REGISTER[$1] += int(($2 == "inc") ? $3 : -$3)
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ > -?[[:digit:]]+$/ {
    if (REGISTER[$5] > int($7)) {
        REGISTER[$1] += int(($2 == "inc") ? $3 : -$3)
    }
    next
}
{
    aoc::data_error()
}
END {
    for (r in REGISTER) {
        if (!largest || (REGISTER[largest] < REGISTER[r])) {
            largest = r
        }
    }
    if (DEBUG) {
        printf("Largest register %s = ", largest) > DFILE
    }
    print REGISTER[largest]
}
