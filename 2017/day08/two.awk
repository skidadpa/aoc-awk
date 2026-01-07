#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
BEGIN {
    largest_val = 0
}
function update_register(r, op, val) {
    REGISTER[r] += (op == "inc") ? val : -val
    if (largest_val < REGISTER[r]) {
        largest_val = REGISTER[r]
    }
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ < -?[[:digit:]]+$/ {
    if (REGISTER[$5] < int($7)) {
        update_register($1, $2, int($3))
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ <= -?[[:digit:]]+$/ {
    if (REGISTER[$5] <= int($7)) {
        update_register($1, $2, int($3))
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ == -?[[:digit:]]+$/ {
    if (REGISTER[$5] == int($7)) {
        update_register($1, $2, int($3))
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ != -?[[:digit:]]+$/ {
    if (REGISTER[$5] != int($7)) {
        update_register($1, $2, int($3))
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ >= -?[[:digit:]]+$/ {
    if (REGISTER[$5] >= int($7)) {
        update_register($1, $2, int($3))
    }
    next
}
/^[[:lower:]]+ ((inc)|(dec)) -?[[:digit:]]+ if [[:lower:]]+ > -?[[:digit:]]+$/ {
    if (REGISTER[$5] > int($7)) {
        update_register($1, $2, int($3))
    }
    next
}
{
    aoc::data_error()
}
END {
    print largest_val
}
