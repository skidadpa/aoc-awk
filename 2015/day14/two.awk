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
    distance[$1] = flytime[$1] = resttime[$1] = points[$1] = 0
}
END {
    for (i = 1; i <= 2503; ++i) {
        for (r in distance) {
            if (++flytime[r] <= duration[r]) distance[r] += speed[r];
            else if (++resttime[r] >= rest[r]) flytime[r] = resttime[r] = 0
            if (distance[r] > leader) leader = distance[r]
        }
        for (r in distance) if (distance[r] == leader) ++points[r]
    }
    for (r in points) if (!winner || points[r] > points[winner]) winner = r
    if (DEBUG) {
        for (r in distance) print r, points[r] > DFILE
        print winner > DFILE
    }
    print points[winner]
}
