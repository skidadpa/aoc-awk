#!/usr/bin/env gawk -f
@include "../../lib/aoc.awk"
(NF != 15) { aoc::data_error() }
($0 !~ / can fly [0-9]+ km\/s for [0-9]+ seconds, but then must rest for [0-9]+ seconds\./) {
    aoc::data_error()
}
{
    speed[$1] = $4
    duration[$1] = $7
    rest[$1] = $14
    distance[$1] = flytime[$1] = resttime[$1] = 0
}
END {
    for (i = 1; i <= 2503; ++i) for (r in distance) {
        if (++flytime[r] <= duration[r]) distance[r] += speed[r];
        else if (++resttime[r] >= rest[r]) flytime[r] = resttime[r] = 0
    }
    for (r in distance) if (!winner || distance[r] > distance[winner]) winner = r
    if (DEBUG) {
        for (r in distance) print r, distance[r] > DFILE
        print winner > DFILE
    }
    print distance[winner]
}
